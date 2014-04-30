/*
 License
 Summary
 
 License does not expire.
 Can be used on unlimited sites, servers
 Source-code or binary products cannot be resold or distributed
 Non-commercial use only
 Can modify source-code but cannot distribute modifications (derivative works)
 Attribution to software creator must be made as specified:
 
 If app will be available on the App Store you must provide a way to download my app. It can be link on the about page to the app.
 
 http://www.binpress.com/license/view/l/1549f46cb77285f4a8188bcfb861d623
 
 */
#import "XMLData.h"
#import "Location.h"
#import "Opens.h"
#import "Station.h"
#import "MealPeriod.h"
#import "MenuItem.h"
@interface XMLData()
{
    
}

@property (nonatomic, copy) void (^sucessBlock)(XMLData *data);
@property (nonatomic, copy) void (^errorBlock)(NSError *error);
@property(nonatomic,strong) NSOperationQueue * queue;
@end


@implementation XMLData

@synthesize locationsArray;
@synthesize locationsInfoArray;
@synthesize generalInfo, contactEmail, contactNumber;
@synthesize extraInfo; 
@synthesize date;

-(instancetype)init{
    if(self = [super init]){
        _queue = [NSOperationQueue mainQueue];
        locationsArray=[[NSMutableArray alloc]initWithCapacity:0];
        locationsInfoArray=[[NSMutableArray alloc]initWithCapacity:0];
        generalInfo=@"";
        contactNumber=@"";
        contactEmail=@"";
        extraInfo=[[NSMutableDictionary alloc]initWithCapacity:0];
    }
    return self;
}

/**
 *  Downloading, parsing and merging data.
 *
 *  @param successBlock executed whenever operation is completed
 *  @param errorBlock   exuecuted whenever operation is interreptued
 */
-(void) startDownloadingWithCompletionBlock:(void(^)())successBlock andError: (void(^)(NSError * error))errorBlock {
    self.sucessBlock = [successBlock copy];
    self.errorBlock = [errorBlock copy];
    
    NSURL * url=[[NSURL alloc] initWithString:CHARTWELLURL];
	NSURLRequest *  request = [[NSURLRequest alloc]initWithURL:url];
    request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:40];
   // [url release];
    
    [NSURLConnection sendAsynchronousRequest:request queue:  _queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError){
            NSURL * url=[[NSURL alloc] initWithString:APPZMANINFO];
            NSURLRequest *  request = [[NSURLRequest alloc]initWithURL:url];

            [NSURLConnection sendAsynchronousRequest:request queue:  _queue completionHandler:^(NSURLResponse *uwf_response, NSData *uwf_data, NSError *uwf_connectionError) {
                if(!uwf_connectionError){
                    [self mergeData:data andResponseExtraData:uwf_data];
                }
                else{
                    self.errorBlock(connectionError);
                }
            }];
        }
        else{
            self.errorBlock(connectionError);
        }
    }];
}


-(void)mergeData:(NSData *)responseData andResponseExtraData:(NSData *)responseExtraData{
    if(responseData!=nil&&responseExtraData!=nil)
	{
        NSError * error;
        GDataXMLDocument * chartwells_xml_data=[[GDataXMLDocument alloc]initWithData:responseData options:0 error:&error];
		GDataXMLDocument * uwf_xml_data=[[GDataXMLDocument alloc]initWithData:responseExtraData options:0 error:&error];
        
        if (uwf_xml_data == nil||chartwells_xml_data==nil) {
            self.errorBlock(error);
            NSLog(@"Error%@", error);
            return;
        }
        else{
            [self parsingChartwellsData:chartwells_xml_data];
            [self parsingUWFData:uwf_xml_data];
            
            // Calling method that will add extra info
            if(self.locationsArray.count>0)
            {
                for(Location *loc in self.locationsArray)
                {
                    for(Location *locInfo in self.locationsInfoArray)
                    {
                        NSString *string = loc.name;
                        if ([string rangeOfString:locInfo.name].location == NSNotFound) {
                        } else {
                            loc.latitude=locInfo.latitude;
                            loc.longitude=locInfo.longitude;
                            loc.info=locInfo.info;
                            loc.contactEmail=locInfo.contactEmail;
                            loc.contactNumber=locInfo.contactNumber;
                            loc.address=locInfo.address;
                            loc.openHours=locInfo.openHours;
                        }
                    }
                }
                self.sucessBlock(self);
            }
            else{
                self.errorBlock(nil);
            }
        }
	}
    else{
        NSLog(@"Something went terribly wrong");
    }
}






-(void)parsingUWFData:(GDataXMLDocument *)dataXML{
  
    NSArray *generalInfoArray = [dataXML.rootElement elementsForName:@"GeneralInfo"];
    for (GDataXMLElement *gI in generalInfoArray)
    {
        NSArray * descArray= [gI elementsForName: @"Description"];
        for(GDataXMLElement * g in descArray)
        {
            self.generalInfo=[g stringValue];
        //    NSLog(@"General Info %@", self.generalInfo);
            
        }
        NSArray * emailArray= [gI elementsForName: @"ContactEmail"];
        for(GDataXMLElement * g in emailArray)
        {
            self.contactEmail=[g stringValue];
         //   NSLog(@"Contact Email %@", self.contactEmail);
        }
        NSArray * phoneArray= [gI elementsForName: @"ContactPhone"];
        for(GDataXMLElement * g in phoneArray)
        {
            self.contactNumber=[g stringValue];
           // NSLog(@"Contact Number %@", self.contactNumber);
        }
    }
        
    NSArray *locations = [dataXML.rootElement elementsForName:@"Location"];
    for (GDataXMLElement *location in locations)
    {
        Location *loc=[[Location alloc]init];
        GDataXMLNode * locationNameXML=[location attributeForName: @"name"];
        NSString * locationName=[locationNameXML stringValue];
        loc.name=locationName; 
        GDataXMLNode * locationLatitude=[location attributeForName: @"Latitude"];
        loc.latitude=[locationLatitude stringValue];
           
        GDataXMLNode * locationLongitude=[location attributeForName: @"Longitude"];
        loc.longitude=[locationLongitude stringValue];             
        if([(NSArray *) [location elementsForName: @"Description"] count]>0){
            GDataXMLNode * info=[[location elementsForName: @"Description"]objectAtIndex:0];
            loc.info=[info stringValue]; 
        }
            
        NSArray * descArray= [location elementsForName: @"Description"];
        for(GDataXMLElement * g in descArray)
        {
            loc.info=[g stringValue];
            // NSLog(@"General Info %@", self.generalInfo);
        }
        NSArray * emailArray= [location elementsForName: @"ContactEmail"];
        for(GDataXMLElement * g in emailArray)
        {
            loc.contactEmail=[g stringValue];
            // NSLog(@"Contact Email %@", self.contactEmail);
        }
        NSArray * phoneArray= [location elementsForName: @"ContactPhone"];
        for(GDataXMLElement * g in phoneArray)
        {
            loc.contactNumber=[g stringValue];
            // NSLog(@"Contact Number %@", loc.contactNumber);
        }
        NSArray * addressArray= [location elementsForName: @"LocationAddress"];
        for(GDataXMLElement * g in addressArray)
        {
            loc.address=[g stringValue];
        }   
            
        NSArray *openXMLArray=[location elementsForName:@"Open"];
        if(openXMLArray.count>0)
        {	
            for(int i=0;i<openXMLArray.count; i++){
                GDataXMLElement *openXML=[openXMLArray objectAtIndex:i];
                Opens *openHours=[[Opens alloc]init];
                openHours.openDay=[[openXML attributeForName:@"day"]stringValue];
                openHours.begin=[[openXML attributeForName:@"begin"]stringValue];
                openHours.end=[[openXML attributeForName:@"end"]stringValue];
                //Adding this to the location hours;
                [loc.openHours addObject:openHours];
                [openHours release];
            }
        }
        [locationsInfoArray addObject: loc];
        [loc release];
     }
}


-(void)parsingChartwellsData:(GDataXMLDocument *)dataXML{
	NSArray *dateArray = [dataXML.rootElement elementsForName:@"Date"];
    if([dateArray count]>0)//Message received
	{
        date=[[dateArray objectAtIndex:0]stringValue];
    }
    
    
    NSArray *messageArray = [dataXML.rootElement elementsForName:@"Message"];
	
    if([messageArray count]>0)//Message received
	{
		//NSLog(@"Message Received");
		message=[[messageArray objectAtIndex:0]stringValue];
		if([message isEqualToString:@"Success"])
		{	
            // Checking locations
			NSArray *locations = [dataXML.rootElement elementsForName:@"Location"];
			if([locations count]>0)
			{
				for (GDataXMLElement *location in locations)
				{
                    Location *loc=[[Location alloc]init];
					loc.locationId=locationId;
                    locationId++;
                    GDataXMLNode * locationNameXML=[location attributeForName: @"name"];
					// NSLog(@"Location %@", [locationNameXML stringValue]);
					NSString * locationName=[locationNameXML stringValue];
					loc.name=locationName; 
                    NSArray *openXMLArray=[location elementsForName:@"Open"];
						if(openXMLArray.count>0)
						{	
							for(int i=0;i<openXMLArray.count; i++){
								GDataXMLElement *openXML=[openXMLArray objectAtIndex:i];
								Opens *openHours=[[Opens alloc]init];
								openHours.openDay=[[openXML attributeForName:@"day"]stringValue];
								openHours.begin=[[openXML attributeForName:@"begin"]stringValue];
								openHours.end=[[openXML attributeForName:@"end"]stringValue];
								//Adding this to the location hours;
								[loc.openHours addObject:openHours];
								[openHours release];
							}
						}
					NSArray *stationXMLArray=[location elementsForName:@"Station"];
					if(stationXMLArray.count>0)
					{	
						for (GDataXMLElement *stationXML in stationXMLArray)
						{
							//Parsing stations
							Station *station=[[Station alloc]init];
							GDataXMLNode * stationNameXML=[stationXML attributeForName: @"name"];
							station.name=[stationNameXML stringValue];
						    //NSLog(@"Station: %@", station.name);
							NSArray *stationOpenXMLArray=[stationXML elementsForName:@"Open"];
								for(int i=0;i<stationXMLArray.count; i++){
									GDataXMLElement *openXML=[stationOpenXMLArray objectAtIndex:i];
									Opens *openHours=[[Opens alloc]init];
									openHours.openDay=[[openXML attributeForName:@"day"]stringValue];
									openHours.begin=[[openXML attributeForName:@"begin"]stringValue];
									openHours.end=[[openXML attributeForName:@"end"]stringValue];
									[station.openHours addObject:openHours];
									[openHours release];	
								}//End of open									
							
                            //Parsing meal period
							NSArray *mealPeriodXMLArray=[stationXML elementsForName:@"MealPeriod"];
							if(mealPeriodXMLArray.count>0)
							{	
								for (GDataXMLElement *mealXML in mealPeriodXMLArray)
								{
									
									MealPeriod *mealPeriod=[[MealPeriod alloc]init]; 
									GDataXMLNode * mealNameXML=[mealXML attributeForName: @"name"];
									mealPeriod.name=[mealNameXML stringValue];
									//NSLog(@"%@",mealPeriod.name);
									
									NSArray *mealOpenXMLArray=[mealXML elementsForName:@"Open"];
									for(int i=0;i<mealOpenXMLArray.count; i++){
										GDataXMLElement *openXML=[stationOpenXMLArray objectAtIndex:i];
										Opens *openHours=[[Opens alloc]init];
										openHours.openDay=[[openXML attributeForName:@"day"]stringValue];
										openHours.begin=[[openXML attributeForName:@"begin"]stringValue];
										openHours.end=[[openXML attributeForName:@"end"]stringValue];
										[mealPeriod.openHours addObject:openHours];
										[openHours release];
                                    }
                                    NSArray *menuItemXMLArray=[mealXML elementsForName:@"MenuItem"];
									for (GDataXMLElement *menuItemXML in menuItemXMLArray)
									{
										MenuItem * menuItem=[[MenuItem alloc]init];
										NSArray *mi= [menuItemXML elementsForName:@"Name"];
										
										if(mi.count>0)
										{
											menuItem.name=[[mi objectAtIndex:0]stringValue];
											//NSLog(@"Menu Item: %@", menuItem.name);
										}
										NSArray *mp= [menuItemXML elementsForName:@"Price"];
										if(mp.count>0)
										{
											menuItem.price=[[mp objectAtIndex:0]stringValue];
											//NSLog(@"Menu Item Price: %@", menuItem.price);
										}
										[mealPeriod.menuItems addObject:menuItem];
										[menuItem release];
									}
                                    [station.mealPeriods addObject:mealPeriod];
									[mealPeriod release];
								}
							} // Meal Period
                            [loc.stations addObject: station];
							[station release];
						}	
					} //end of station
					[self.locationsArray addObject: loc];
					[loc release];
				} //end of location
			}		
			else{
			// NSLog(@"Message Received: %", message);
			return;
		}
	}//End of main if
	else { //No messages Fatal Error
	}
  }
}


-(void) dealloc{
	[locationsArray release];
	[locationsInfoArray release];
	[extraInfo release];
	[super dealloc];
}

@end
