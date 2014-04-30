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

#import "StationsTable.h"
#import "Station.h"
#import "Location.h"
#import "MealPeriod.h"
#import "Opens.h"
#import "UpdaterViewController.h"
#import "XMLData.h"

@implementation StationsTable
@synthesize stations;
@synthesize station;
@synthesize location;
@synthesize toolbar;
@synthesize bannerTable;

UpdaterViewController * c;


-(void) willResignActive{
    [c.view removeFromSuperview];
}


-(void)didBecomeActive{
    //Let's check when was the last update hmm maybe we will store it in the user defaults?

    NSDate * lastUpdate=[defaults objectForKey:@"lastUpdate"];
 
    NSTimeInterval howRecent = [lastUpdate timeIntervalSinceNow];

    if(lastUpdate==nil)// App wasn't updated so we need to do it now
    {
        [self updateInformation];

    }
    else{
        //Check for the items
        if([[menu allValues]count]==0){
            [self updateInformation];
            }
            if (abs(howRecent) < 600.0)
            {
            //    NSLog(@"App was updated less than 10 minutes ago");
            }
            else{
            //    NSLog(@"App was updated more than 10 minutes ago");
                [self updateInformation];
            }
        }
}



-(IBAction) updateInformation{
    c.delegate=self;
    [c startParsing];
    [self.view addSubview:c.view];
    c.view.frame = self.view.bounds;
    
}


-(void)finished{
 [c.view removeFromSuperview];
  [c.activityIndicator stopAnimating];
    for(Location *loc in c.xmlData.locationsArray)
    {
        if([loc.name isEqualToString:self.location.name])
        {
            self.location=loc;
            break;
        }
        
    }
    
   // [menu removeAllObjects];
   //     NSLog(@"%d number of segments", MenuSegmentedControl.numberOfSegments);
   // [MenuSegmentedControl removeSegmentAtIndex:1 animated:NO];
    
    [self prepareMenu];   
    [self showHoursAndAnAddress];
    
       
    [MenuSegmentedControl removeAllSegments];
    for(int i=0;i<[[menu allKeys]count];i++)
    {
        NSString *title=[mutableMeals objectAtIndex:i];
        [MenuSegmentedControl insertSegmentWithTitle: title atIndex:i animated:YES];
    }
    if(mutableMeals.count==1)
    {
     //   NSLog(@"%d number of segments inside mutable count 1", MenuSegmentedControl.numberOfSegments);
        [MenuSegmentedControl setSelectedSegmentIndex:0];
        [MenuSegmentedControl setHidden:YES];
        //Move the label Up and table as well:
        //table.frame=CGRectMake(0, 110, 320, 306);
        //MenuSubjectToChange.frame=CGRectMake(77, 90, 166, 21);
        
    }
    if(mutableMeals.count>1){ 
       // NSLog(@"%d number of segments", MenuSegmentedControl.numberOfSegments);
        MenuSegmentedControl.selectedSegmentIndex=0;
        // [self mealTypeChanged:0];
        [MenuSegmentedControl setHidden:NO];
    }

     [self mealTypeChanged:MenuSegmentedControl];
    [defaults synchronize];
    
}


- (IBAction)emailAction:(id)sender {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    NSArray * a=[[NSArray alloc]initWithObjects:location.contactEmail, nil];
    [controller setToRecipients:a];
    [controller setSubject:@"Dine on Campus - Sent From iPhone App"];
    [controller setMessageBody:@"Hello there." isHTML:NO]; 
    if (controller)  [self presentViewController:controller animated:YES completion:nil];;
   
    
    [controller release];
    [a release];
}


- (IBAction)callAction:(id)sender {
    NSString *callToURLString = [NSString stringWithFormat:@"tel:%@", location.contactNumber];
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:callToURLString]])
	{
		// there was an error trying to open the URL. We'll ignore for the time being.
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"The call can't be placed." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
	}
}


- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error; {
    if (result == MFMailComposeResultSent) {
        // NSLog(@"It's away!");
    }
       [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction) showInfo {
    description.text=location.info;
    phoneLabel.text=location.contactNumber;
    emailLabel.text=location.contactEmail;

    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:[self.view superview] cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [self.view addSubview:infoView];
    infoView.frame= self.view.bounds;
    
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


-(void)prepareMenu{    
    
    [menu removeAllObjects];
    [mutableMeals removeAllObjects];
    
     for(Station *_station in location.stations)
    {
        for(MealPeriod *mp in _station.mealPeriods)
        {
            NSString * temp=mp.name;
            BOOL itsIn=NO;
            
            for(NSString * str in mutableMeals)
            {    
                if([str isEqualToString:temp]){
                    itsIn=TRUE; 
                }
            }
            if(itsIn==NO)
            {
                [mutableMeals addObject:temp]; 
            }
        }
    }
     
   // NSLog(@"Mutable meals inside prepare meals %@", mutableMeals );
    
    for(Station *_station in location.stations)
    {
        //  NSArray * mealPeriods= station.mealPeriods;
        for(MealPeriod *mp in _station.mealPeriods)
        {
            for(NSString * s in mutableMeals) // Looping through meals in mutable meals array
            {
                if([mp.name isEqualToString: s]) // if the name of the meal in single meal period is the same as in the mutable array
                {
                       if([menu objectForKey:s]) // if object exists
                       {
                           NSMutableDictionary * container=[menu objectForKey:s]; //NSdictionary inside the NSDictionary
                           
                           NSMutableArray * tempMenu=[container objectForKey:_station.name];
                           if(!tempMenu)
                           {
                                [container setObject:mp.menuItems forKey:_station.name];
                                [menu setObject:container forKey:s];
                           }
                           
                       }
                       else{
                           NSMutableDictionary * container=[[NSMutableDictionary alloc]initWithCapacity:0];
                           [container setObject:mp.menuItems forKey:_station.name];
                           [menu setObject:container forKey:s];
                           [container release];
                       }
                }
            }
        }
    }
}


- (IBAction)mealTypeChanged:(id)sender {
 
    //UISegmentedControl * c=(UISegmentedControl *) sender;
    int selectedSegment=(int) MenuSegmentedControl.selectedSegmentIndex;
    
    NSString * title=[MenuSegmentedControl titleForSegmentAtIndex:selectedSegment];

    for(NSString * s in [menu allKeys])
    {
        if([title isEqualToString:s])
        {
            currentKey=s;
        }
    }
    [table reloadData];
}


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        c=[[ UpdaterViewController  alloc]initWithNibName:@"NautilusMarketXMLViewController" bundle:nil];
        c.view.alpha=1;
        [c.activityIndicator startAnimating];
        // Custom initialization.
		stations=[[NSMutableArray alloc]initWithCapacity:0];
        station=[[Station alloc]init];
        mutableMeals=[[NSMutableArray alloc]initWithCapacity:0];
        menu=[[NSMutableDictionary alloc]initWithCapacity:0];
    }
    return self;
}


-(IBAction)dismiss{
	    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void) showHoursAndAnAddress{
    locationName.text=location.name;
    locationAddress.text=location.address;
    locationNameInfo.text=location.name;
    
    //checking hours
    int seconds=-6 *60 * 60;
    NSDate*_date=[NSDate date];
    NSTimeZone*zone=[NSTimeZone timeZoneForSecondsFromGMT:seconds];
	[NSTimeZone setDefaultTimeZone:zone];
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *weekdayComponents =
	[gregorian components:(NSDayCalendarUnit| NSWeekdayCalendarUnit|NSWeekCalendarUnit) fromDate:_date];
    NSInteger dayInt=[weekdayComponents weekday];
    [gregorian release];
    // NSLog(@"Day as int %d", dayInt);

    NSString *open;
    NSString *close;
    NSString *hours;
    int theHourBegin;
    int theMinutesBegin;
    int theHourClose;
    int theMinutesClose;
    
   for(Opens * opens in location.openHours)
   {
       int openDay=[opens.openDay intValue];
       // NSLog(@"%d", openDay);
       if(dayInt==openDay)// it is open 
       {
           float beginHour= [[opens begin] floatValue];
           float closeHour= [[opens end] floatValue];        
           
           // Convert beginning hour to integers for formatting on screen
           theHourBegin = beginHour;
           theMinutesBegin = (beginHour * 100) - (theHourBegin * 100);
           
           // Convert closing time to integers for formatting on screen
           theHourClose = closeHour;
           theMinutesClose = (closeHour * 100) - (theHourClose * 100);
           
           //Check for zero
           if (beginHour==0) {
                openFrom.text=@"Closed";
           }
           else{
           
               if(theHourBegin>=12) // After 12 noon
               {
                   theHourBegin=theHourBegin-12;
                   if (theMinutesBegin >= 10){  // 2 digit numerical value for minutes
                       open=[NSString stringWithFormat:@"Open from %2i:%2i p.m.", theHourBegin, theMinutesBegin];
                   }
                   else {                       // 1 digit numerical value for minutes
                       open=[NSString stringWithFormat:@"Open from %2i:0%1i p.m.", theHourBegin, theMinutesBegin];
                   }
               }
               else{  // Before 12 noon
                    if(theMinutesBegin >= 10){  // 2 digit numerical value for minutes
                       open=[NSString stringWithFormat:@"Open from %2i:%2i a.m.", theHourBegin, theMinutesBegin];
                   }
                   else{                        // 1 digit numerical value for minutes
                       open=[NSString stringWithFormat:@"Open from %2i:0%1i a.m.", theHourBegin, theMinutesBegin];      
                    }
               }
               if(theHourClose>=12)  // After 12 noon
               {
                   theHourClose=theHourClose-12;
                   if(theMinutesClose >=10){     // 2 digit numerical value for minutes
                       close=[NSString stringWithFormat:@" to %2i:%2i p.m.", theHourClose, theMinutesClose];
                   }
                   else {                        // 1 digit numerical value for minutes
                       close=[NSString stringWithFormat:@" to %2i:0%1i p.m.", theHourClose, theMinutesClose];    
                    }
               }
               else { 
                   if(theMinutesClose >= 10){  // 2 digit numerical value for minutes
                       close=[NSString stringWithFormat:@" to %2i:%2i a.m.", theHourClose, theMinutesClose];
                   }
                   else {   // 1 digit numerical value for minutes
                       close=[NSString stringWithFormat:@" to %2i:0%1i a.m.", theHourClose, theMinutesClose];  
                   }
                
               }
               hours = [open stringByAppendingString:close]; //combine into one string
               openFrom.text=hours;  // load label
               break;
           }
       }
   }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    defaults=[NSUserDefaults standardUserDefaults];
    [table setAllowsSelection:NO];
    
    NSString *emailText=[NSString stringWithFormat:@"Email %@",  location.contactEmail];
    NSString *phoneText=[NSString stringWithFormat:@"Email %@",  location.contactNumber];
    
    [emailButton setTitle:emailText forState:UIControlStateNormal];

    [phoneButton setTitle:phoneText forState:UIControlStateNormal];
 
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(didBecomeActive) 
                                                 name: @"didBecomeActive" 
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(willResignActive) 
                                                 name: @"willResignActive" 
                                               object: nil];
    //Checking for updates
    [self didBecomeActive];
    self.bannerTable.delegate = self;
    menu=[[NSMutableDictionary alloc]initWithCapacity:0];
}
#pragma mark Table Methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger k=[[[menu objectForKey:currentKey]allKeys] count];
       // NSLog(@"Sections %d %@ %@", k, [menu objectForKey:currentKey],[[menu objectForKey:currentKey]allKeys]);
	return k;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
    NSInteger k=[[[[menu objectForKey:currentKey]allValues]objectAtIndex:section]count];

    return k;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * text=[NSString stringWithFormat:@"%@ %@",
    [[[menu objectForKey:currentKey]allKeys]objectAtIndex:section],
    c.xmlData.date] ;
    return text;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
		
    NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
    }
    NSString * text=[[[[[menu objectForKey:currentKey]allValues]objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]name];
    cell.textLabel.text=text;
    return cell;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [MenuSegmentedControl release];
    MenuSegmentedControl = nil;
    [toolbar release];
    toolbar = nil;
    [phoneLabel release];
    phoneLabel = nil;
    [emailLabel release];
    emailLabel = nil;
    [description release];
    description = nil;
    [locationNameInfo release];
    locationNameInfo = nil;
    [locationName release];
    locationName = nil;
    [locationAddress release];
    locationAddress = nil;
    [openFrom release];
    openFrom = nil;
    self.bannerTable.delegate = nil;
    self.bannerTable = nil;
    [emailButton release];
    emailButton = nil;
    [phoneButton release];
    phoneButton = nil;
    [MenuSubjectToChange release];
    MenuSubjectToChange = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.stations=nil;
    self.station=nil;
    c=nil;
}


- (void)dealloc {
    //[c release];
    [mutableMeals release];
	[stations release];
    [MenuSegmentedControl release];
    [toolbar release];
    [phoneLabel release];
    [emailLabel release];
    [description release];
    [locationNameInfo release];
    [locationName release];
    [locationAddress release];
    [openFrom release];
    [bannerTable release];
    [emailButton release];
    [phoneButton release];
    [MenuSubjectToChange release];
    [super dealloc];
}


#pragma mark ADBannerViewDelegate methods

-(void)bannerViewDidLoadAd:(ADBannerView *)bannerTable
{
    [self layoutForCurrentOrientation:YES];
}


-(void)bannerView:(ADBannerView *)bannerTable didFailToReceiveAdWithError:(NSError *)error
{
    [self layoutForCurrentOrientation:YES];
}


-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)bannerTable willLeaveApplication:(BOOL)willLeave
{
    return YES;
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
   // bannerTable.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    bannerHeight = bannerTable.bounds.size.height; 
	
    // Depending on if the banner has been loaded, we adjust the content frame and banner 
    // location to accomodate the ad being on or off screen.
    // This layout is for an ad at the bottom of the view.
    if(bannerTable.bannerLoaded)
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
                         bannerTable.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, bannerTable.frame.size.width, bannerTable.frame.size.height);
                     }];
}
@end
