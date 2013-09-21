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
#import "MapViewController.h"
#import "Location.h" 
#import "XMLData.h"
#import "StationsTable.h"
#define iphoneScaleFactorLatitude   9.0    
#define iphoneScaleFactorLongitude  11.0  

@implementation MapViewController
NSMutableArray * shopsToShow;
int tagIndex;
@synthesize mapView,  locationsToFilter, toolbar, banner;
MKPointAnnotation *nautilus, *subGeneration, *starbucks, *outTakes, *terraJuice, *commons;


-(void) finished{
    [c.view removeFromSuperview];
    self.locationsToFilter=c.xmlData.locationsArray;
    [self showAllLocations];
    [self updateDescriptions];
}


-(void) updateDescriptions{
    description.text=c.xmlExtraData.generalInfo;
    phoneLabel.text=c.xmlExtraData.contactNumber;
    emailLabel.text=c.xmlExtraData.contactEmail;
    phoneTextView.text=c.xmlExtraData.contactNumber;
    NSString * emailString=[NSString stringWithFormat:@"Email %@",c.xmlExtraData.contactEmail];
    NSString * phoneString=[NSString stringWithFormat:@"Phone %@",c.xmlExtraData.contactNumber];
    [emailButton setTitle:emailString forState:UIControlStateNormal];
    [phoneButton setTitle:phoneString forState:UIControlStateNormal];
}


-(void) updateInformation{
    [self.view addSubview:c.view];
    c.view.frame= self.view.bounds;
    
    [c startParsing];
}


-(IBAction) showInfo{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:[self.view superview] cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [self.view addSubview:infoView];
    infoView.frame =self.view.bounds;
    
    [UIView commitAnimations];
}


-(IBAction) done{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:[self.view superview] cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [infoView removeFromSuperview];
    [UIView commitAnimations];
}

#pragma mark calling, sending emails and othere communication methods

- (IBAction)openLink:(id)sender {
    NSString *webLink = [NSString stringWithFormat:@"http://www.dineoncampus.com/uwf"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webLink]];
}


- (IBAction)openFacebook:(id)sender {
    NSString *webLink = [NSString stringWithFormat:@"http://www.facebook.com/UWFDining"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webLink]];
}


- (IBAction)emailAction:(id)sender {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    NSArray * a=[[NSArray alloc]initWithObjects:c.xmlExtraData.contactEmail, nil];
    [controller setToRecipients:a];
    [controller setSubject:@"Dine on Campus - Sent From iPhone App"];
    [controller setMessageBody:@"Hello there." isHTML:NO]; 
    if (controller)  [self presentViewController:controller animated:YES completion:nil];;
    [controller release];
    [a release];
}


- (IBAction)callAction:(id)sender {
    NSString *callToURLString = [NSString stringWithFormat:@"tel:%@", c.xmlExtraData.contactNumber];
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:callToURLString]])
	{
		// there was an error trying to open the URL. We'll ignore for the time being.
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"You can't place the call." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        
	}
}


#pragma Mark Mail Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        // NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void) showAllLocations{
     for (Location * loc in locationsToFilter)
     {      
         [loc getCoordinate];
         [mapView addAnnotation:loc];
     
     }
}


#pragma mark notifications
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(didBecomeActive) 
                                                     name: @"didBecomeActive" 
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(willResignActive) 
                                                     name: @"willResignActive" 
                                                   object: nil];
    }
    return  self;
}


-(void) willResignActive{
    [c.view removeFromSuperview];
}


-(void)didBecomeActive{
    [self updateInformation];
}


#pragma mark filtering annotations:
-(void)filterAnnotations:(NSArray *)placesToFilter{
    [mapView removeAnnotations:mapView.annotations];
    float latDelta=mapView.region.span.latitudeDelta/iphoneScaleFactorLatitude;
    float longDelta=mapView.region.span.longitudeDelta/iphoneScaleFactorLongitude;
    [placesToFilter makeObjectsPerformSelector:@selector(cleanPlaces)];
    shopsToShow=[[NSMutableArray alloc] initWithCapacity:0];
    if(shopsToShow==nil){
       
    }
    if(shopsToShow.count>0){
        [shopsToShow removeAllObjects];
    }
        for (int i=0; i<[placesToFilter count]; i++) {
        Location *checkingLocation=[placesToFilter objectAtIndex:i];
        CLLocationDegrees latitude = [checkingLocation.latitude floatValue];
        CLLocationDegrees longitude = [checkingLocation.longitude floatValue];
        
        bool found=FALSE;
        for (Location *tempPlacemark in shopsToShow) {
            if(fabs([tempPlacemark.latitude floatValue]-latitude) < latDelta && fabs([tempPlacemark.longitude floatValue]-longitude)<longDelta ){
                [mapView removeAnnotation:checkingLocation];
                found=TRUE;
                [tempPlacemark addPlace:checkingLocation];
                break;
            }
        }
        if (!found) {
           [checkingLocation getCoordinate];
            [shopsToShow addObject:checkingLocation];
            [mapView addAnnotation:checkingLocation];
        }
    }
  
    [shopsToShow release];
}



-(IBAction) segmentedControlSwitched:(id)sender{
       
if( [(UISegmentedControl *) sender selectedSegmentIndex]==0)
   {
     self.mapView.mapType = MKMapTypeStandard;
   }
if( [(UISegmentedControl *) sender selectedSegmentIndex]==1)
    {
    self.mapView.mapType = MKMapTypeSatellite;  
    } 
if( [(UISegmentedControl *) sender selectedSegmentIndex]==2)
    {
    self.mapView.mapType = MKMapTypeHybrid;     
    }
}


- (void)gotoLocation
{
    // start off by default in UWF
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 30.5477;
    newRegion.center.longitude = -87.219001;
    newRegion.span.latitudeDelta = 0.007872;
    newRegion.span.longitudeDelta = 0.0109863;
    [self.mapView setRegion:newRegion animated:YES];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    //[self presentModalViewController:c animated:YES];
    //[c release];
}


- (void)viewDidLoad
{   
    //[banner removeFromSuperview];
   // [banner cancelBannerViewAction];
    self.banner.delegate = self;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    

    [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(didBecomeActive) 
                                                 name: @"didBecomeActive" 
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(willResignActive) 
                                                 name: @"willResignActive" 
                                               object: nil];

    
    mapAnnotations=[[NSMutableArray alloc]initWithCapacity:0];
    pickerLocations=[[NSMutableArray alloc]initWithCapacity:0];
    locationsToFilter=[[NSMutableArray alloc]initWithCapacity:0];
    c=[[NautilusMarketXMLViewController alloc]initWithNibName:@"NautilusMarketXMLViewController" bundle:nil];
    c.delegate=self;
    mapView.showsUserLocation=YES;
    self.mapView.mapType = MKMapTypeStandard; 
    if (nil == locationManager)
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500;    
    [locationManager startUpdatingLocation];

    // create a custom navigation bar button and set it to always says "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	[temporaryBarButtonItem release];
    
    [self gotoLocation];    // finally goto UWF
    [self.view addSubview: c.view];
    c.view.frame = self.view.bounds;
    [c startParsing];
}


- (void)viewDidUnload
{
    [phoneTextView release];
    phoneTextView = nil;
    [description release];
    description = nil;
    [emailButton release];
    emailButton = nil;
    [phoneButton release];
    phoneButton = nil;
    [emailLabel release];
    emailLabel = nil;
    [phoneLabel release];
    phoneLabel = nil;
    [pickerLocationsView release];
    pickerLocationsView = nil;
    [_pickerView release];
    _pickerView = nil;
   // self.detailViewController = nil;
    self.mapView = nil;
    mapView.delegate=nil;
    locationManager.delegate=nil;
    self.toolbar = nil;
    self.banner.delegate = nil;
    self.banner = nil;
}

- (void)dealloc 
{
    [mapView release];
    [locationManager release];
    [mapAnnotations release];
    [_pickerView release];
    [pickerLocationsView release];
    [phoneLabel release];
    [emailLabel release];
    [phoneButton release];
    [emailButton release];
    [description release];
    [phoneTextView release];
    [toolbar release];
    [banner release];
    [super dealloc];
}


#pragma mark -
#pragma mark ButtonActions


#pragma mark CoreLocationDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        if(!updated){
            //[self showCurrentLocation];
            updated=TRUE;
        
        }
    }
    // else skip the event and process the next one.
}


-(void) showCurrentLocation{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = mapView.userLocation.coordinate.latitude;
    newRegion.center.longitude = mapView.userLocation.coordinate.longitude;
    newRegion.span.latitudeDelta = 0.007872;
    newRegion.span.longitudeDelta = 0.0109863;
    [self.mapView setRegion:newRegion animated:YES];
}


#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)_control{
 ;
    Location *locationToPush;
    NSString * string= [(Location *) view.annotation title];
    for(Location *loc in self.locationsToFilter)
   {
       if([loc.title isEqualToString:string])
       {
           locationToPush=loc;
       }
   }
        
    StationsTable *table=[[ StationsTable alloc]initWithNibName:@"StationsTable" bundle:nil];
    table.location=locationToPush;
     [self presentViewController:table animated:YES completion:nil];;
    [table release];
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {    MKAnnotationView *v=[[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"self"]autorelease];
        v.annotation=annotation;
        return nil;
    }
    // handle our two custom annotations
    else{   
                
        // try to dequeue an existing pin view first
        static NSString* singleLocation = @"singleLocation";
        MKPinAnnotationView* singlePinView = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:singleLocation];
        
        if (!singlePinView) 
        {
            MKPinAnnotationView* customPinView2 = [[[MKPinAnnotationView alloc]
                                                      initWithAnnotation:annotation reuseIdentifier:singleLocation] autorelease];
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            rightButton.tag=    [(Location *) annotation locationId];            
            customPinView2.animatesDrop = YES;
            customPinView2.canShowCallout = YES;
            
            UIImage *ic=[UIImage imageNamed:@"restaurant-icon.gif"];
            UIImageView *img=[[UIImageView alloc]initWithImage:ic];
            customPinView2.leftCalloutAccessoryView=img;
            customPinView2.rightCalloutAccessoryView = rightButton;
            
            [img release];
            singlePinView= customPinView2;
            singlePinView.annotation=annotation;
            return singlePinView;
         }
        else{
            singlePinView.annotation=annotation;
        return singlePinView;
        }
    }    
    return nil;
}
  


-(void)mapView:(MKMapView *)_mapView regionDidChangeAnimated:(BOOL)animated{
    if (zoomLevel!=_mapView.region.span.longitudeDelta) {     
       // [self filterAnnotations:locationsToFilter];
        zoomLevel=_mapView.region.span.longitudeDelta;
    }
}


#pragma mark Picker View
-(void)showPicker:(id) sender{
    [pickerLocations removeAllObjects];
    [pickerLocations addObjectsFromArray:[mapAnnotations objectAtIndex:tagIndex-1]];
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1];
    pickerLocationsView.frame=CGRectMake(0, 156, 320, 460);
    [UIView commitAnimations];
    
}


- (IBAction)showPickerDetails:(id)sender {
    int select=[_pickerView selectedRowInComponent:0];
    StationsTable *table=[[ StationsTable alloc]initWithNibName:@"StationsTable" bundle:nil];
    table.location=[locationsToFilter objectAtIndex:select];
     [self presentViewController:table animated:YES completion:nil];
    [table release];
    [self hidePicker:nil];
}


- (IBAction)hidePicker:(id)sender {
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1];
    pickerLocationsView.frame=CGRectOffset(self.view.bounds, 0,  CGRectGetMaxY(self.view.bounds));
    [UIView commitAnimations];

    
}


- (IBAction)showPickerLocations:(id)sender {
    [self.view addSubview:pickerLocationsView];
    pickerLocationsView.frame=CGRectOffset(self.view.bounds, 0,  CGRectGetMaxY(self.view.bounds));
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1];
    pickerLocationsView.frame=self.view.bounds;
    [UIView commitAnimations];
    [_pickerView selectRow:2 inComponent:0 animated:1]; // added July 25
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *retval = (id)view;
 
    if (!retval) {
        retval= [[[UILabel alloc] initWithFrame:CGRectMake(30.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)] autorelease];
    }
    retval.textAlignment = NSTextAlignmentLeft;// UITextAlignmentLeft;
    retval.text =[NSString stringWithFormat:@"  %@", [[locationsToFilter objectAtIndex:row]name]];
    retval.font = [UIFont boldSystemFontOfSize:15];
    retval.backgroundColor=[UIColor clearColor];
    
    return retval;
}


-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return locationsToFilter.count;
}




#pragma mark ADBannerViewDelegate methods

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    // NSLog(@"Ad loaded");
    [self layoutForCurrentOrientation:YES];
}


-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    // NSLog(@"Fail to receive Ad");
    [self layoutForCurrentOrientation:YES];
}


-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}


-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}


-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    // by default content consumes the entire view area
    CGRect contentFrame = self.view.bounds;
    CGRect toolbarFrame = self.toolbar.bounds;
    // the banner still needs to be adjusted further, but this is a reasonable starting point
    // the y value will need to be adjusted by the banner height to get the final position
	CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame)-CGRectGetMaxY(toolbarFrame));
    CGFloat bannerHeight = 0.0f;
    
    // First, setup the banner's content size and adjustment based on the current orientation
//    banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;

    bannerHeight = banner.bounds.size.height;
	
    // Depending on if the banner has been loaded, we adjust the content frame and banner location
    // to accomodate the ad being on or off screen.
    // This layout is for an ad at the bottom of the view.
    if(banner.bannerLoaded)
    {
		bannerOrigin.y -= bannerHeight;
    }
    else
    {
		bannerOrigin.y += bannerHeight;
    }
    
    // And finally animate the changes, running layout for the content view if required.
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         banner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, banner.frame.size.width, banner.frame.size.height);
                     }];
}


@end
