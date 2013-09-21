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

#import "NautilusMarketXMLViewController.h"
//#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"
#import "XMLData.h"
#import "Location.h"

@interface NautilusMarketXMLViewController()
{
    GDataXMLDocument *doc;
    GDataXMLDocument *extraDoc;
}
@end


@implementation NautilusMarketXMLViewController
@synthesize progressBar;
@synthesize xmlData;
@synthesize xmlExtraData;
@synthesize delegate;
@synthesize activityIndicator;



-(IBAction) startParsing{
    NSURL * url=[[NSURL alloc] initWithString:CHARTWELLURL];		
	
    NSURLRequest *  request = [[NSURLRequest alloc]initWithURL:url];
       [activityIndicator startAnimating];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         statusLabel.text=@"Updating Menu ";
        [activityIndicator stopAnimating];
        [self parseFromAppzman:data];
        
    }];
}


-(void)mergeData:(NSData *)responseData andResponseExtraData:(NSData *)responseExtraData{
    if(responseData!=nil&&responseExtraData!=nil)
	{
        NSError * error;
        doc=[[GDataXMLDocument alloc]initWithData:responseData options:0 error:&error];
		extraDoc=[[GDataXMLDocument alloc]initWithData:responseExtraData options:0 error:&error];
        
        if (doc == nil||extraDoc==nil) {
			statusLabel.text=@"Information Temporarily Unavailable.";
            NSLog(@"Error%@", error);
            return;
        }
        else{
            xmlData=[[XMLData alloc]initWithGData:doc];
            [xmlData parsing];
            
            xmlExtraData=[[XMLData alloc]initWithGData:extraDoc];
            [xmlExtraData parsingAdditionalData];
            // Calling method that will add extra info
            if(xmlData.locationsArray>0)
            {
                [self addExtraInfo];
            }
        }
	}
    else{
        NSLog(@"Something went terribly wrong");
        statusLabel.text=@"Information Temporarily Unavailable.";
    }
}

-(void)parseFromAppzman:(NSData *)chartwellData{
    NSURL * url=[[NSURL alloc] initWithString:@"http://appzman.com/DineOnCampus/info.xml"];
    NSURLRequest *  request = [[NSURLRequest alloc]initWithURL:url];
    [activityIndicator startAnimating];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *_response, NSData *data, NSError *connectionError) {
      
        [activityIndicator stopAnimating];

        if (!connectionError) {

            [self mergeData:chartwellData andResponseExtraData:data];
        }
        else
        {
          
            NSLog(@"Eror %@", connectionError.debugDescription );
            
        }

        statusLabel.text=@"Validating Data";
    }];
}



//
//    
//    
////    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
////    [request setTimeOutSeconds:90];
////	[request setDelegate:self];
////	[request setDownloadProgressDelegate:progressBar];
////	[request startAsynchronous];
//    [activityIndicator startAnimating];
//    statusLabel.text=@"Updating Menu ";
//    [url release];
//}


-(void) hideUIElements
{   //statusLabel.hidden=YES;
    progressBar.hidden=YES;
    [activityIndicator stopAnimating];
    // [LoadingView removeFromSuperview];
    // [self dismissModalViewControllerAnimated:YES];
}


//- (void)requestFinished:(ASIHTTPRequest *)request
//{
//    NSError *error;
//	NSData *responseData = [request responseData];
//    NSURL *InfoUrl = [[NSURL alloc] initWithString:@"http://appzman.com/DineOnCampus/info.xml"];
//    ASIHTTPRequest *infoRequest = [ASIHTTPRequest requestWithURL:InfoUrl];
//    [infoRequest setTimeOutSeconds:90];
//    [infoRequest startSynchronous];
//    NSError *error1 = [infoRequest error];
//    NSData *responseExtraData;
//    if (!error1) {
//         responseExtraData=[infoRequest responseData];
//    }
//    else
//    {
//        NSString *response = [infoRequest responseString];
//        NSLog(@"Eror %@", response);
//
//    }
//    //  NSData *responseExtraData=[[NSData alloc]initWithContentsOfFile:path];
//    statusLabel.text=@"Validating Data";
//    
//    
//    if(responseData!=nil&&responseExtraData!=nil)
//	{	
//        doc=[[GDataXMLDocument alloc]initWithData:responseData options:0 error:&error];
//		extraDoc=[[GDataXMLDocument alloc]initWithData:responseExtraData options:0 error:&error];
//     
//        if (doc == nil||extraDoc==nil) {
//			statusLabel.text=@"Information Temporarily Unavailable.";	
//            NSLog(@"Error%@", error);
//            return; 
//        }
//        else{
//            xmlData=[[XMLData alloc]initWithGData:doc];
//            [xmlData parsing];
//                       
//            xmlExtraData=[[XMLData alloc]initWithGData:extraDoc];
//            [xmlExtraData parsingAdditionalData];
//            // Calling method that will add extra info
//            if(xmlData.locationsArray>0)
//            {    
//                [self addExtraInfo];
//            }
//        }
//	}
//    else{
//        NSLog(@"Something went terribly wrong");
//    }
//    // [responseExtraData release];
//}


-(void) addExtraInfo{
    for(Location *loc in xmlData.locationsArray)
    {
        for(Location *locInfo in xmlExtraData.locationsInfoArray)
        {
            NSString *string = loc.name;
            if ([string rangeOfString:locInfo.name].location == NSNotFound) {
              //  NSLog(@"string %@ does not contain %@", loc.name, locInfo.name);
            } else {
                // NSLog(@"string %@ does contain %@", loc.name, locInfo.name);
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
   // generalInfo=xmlExtraData.locationsInfoArray obj
    [activityIndicator stopAnimating];
    [delegate finished];
}

//
//- (void)requestFailed:(ASIHTTPRequest *)request
//{
//	NSError *error = [request error];
//	NSLog(@"Error in failed %@", error);
//	statusLabel.text=@"Information Temporarily Unavailable";	
//}
//
//
//-(void)CustomOperationCompleted{
//	NSLog(@"Completed");
//}
//

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [LoadingView release];
    LoadingView = nil;
    [activityIndicator release];
    activityIndicator = nil;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.progressBar=nil;
}


- (void)dealloc {
	[progressBar release];
    [activityIndicator release];
    [LoadingView release];
    [xmlData release];
    [super dealloc];
}

@end
