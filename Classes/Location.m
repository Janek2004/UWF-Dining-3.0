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

#import "Location.h"
@implementation Location
@synthesize name;
@synthesize stations, openHours;
@synthesize info, latitude, longitude;
@synthesize coordinate;
@synthesize currentTitle;
@synthesize currentSubTitle;
@synthesize places;
@synthesize image;
@synthesize contactEmail, contactNumber;
@synthesize locationId;
@synthesize address;


-(NSMutableArray *) getPlaces{
  //  NSLog(@"Inside get Places %@",self.places);
    return self.places;
}


- (NSString *)subtitle{
    if ([places count]==1) {
        return currentSubTitle;
    }
    else{
        return @"";
    }
}


- (NSString *)title{
    
    if ([places count]==1) {
        return name;
    }
    else{
        return name;
    }
}


-(void)addPlace:(Location *)place{
    [places addObject:place];
}


-(CLLocationCoordinate2D)getCoordinate{
    coordinate=CLLocationCoordinate2DMake([self.latitude floatValue], [self.longitude floatValue]);
  //  NSLog(@"%@", self.name);
    return coordinate;
}


-(void)cleanPlaces{
    
    [places removeAllObjects];
    [places addObject:self];
}


-(NSUInteger)placesCount{
    return [places count];
}


-(id)init{
	if((self=[super init]))
	{
		openHours=[[NSMutableArray alloc]initWithCapacity:0];	
		stations=[[NSMutableArray alloc]initWithCapacity:0];	
        places=[[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}


-(void) dealloc{
	[openHours release];
	[stations release];
	[name release];
    [places release];
	self.name=nil;
    self.places=nil;
	[super dealloc];
}

@end
