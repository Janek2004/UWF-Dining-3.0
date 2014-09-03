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

#import "UpdaterViewController.h"
#import "GDataXMLNode.h"
#import "XMLData.h"
#import "Location.h"
/**
 *  Managing XML
 */
@interface UpdaterViewController()
{
    GDataXMLDocument *doc;
    GDataXMLDocument *extraDoc;

	IBOutlet UILabel *statusLabel;
    IBOutlet UIView *LoadingView;
    NSString *generalInfo;

}
/**
 *  progress bar
 */
@property(nonatomic, retain) IBOutlet UIProgressView *progressBar;


@end


@implementation UpdaterViewController


-(IBAction) startParsing{
        [_activityIndicator startAnimating];
        XMLData * xmlData = [[XMLData alloc]init];
        [xmlData startDownloadingWithCompletionBlock:^(NSArray *array, XMLData * data){
                [_activityIndicator stopAnimating];
                self.xmlData =xmlData ;
                [_delegate finished];
                
        } andError:^(NSError *error) {
            NSLog(@" Error %@",error.debugDescription);
            [_activityIndicator stopAnimating];
            statusLabel.text = @"Please Try Again Later.";
            [self performSelector:@selector(finished) withObject:_delegate afterDelay:2];
            [_delegate finished];
        }];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [LoadingView release];
    LoadingView = nil;
    [_activityIndicator release];
    _activityIndicator = nil;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.progressBar=nil;
}


- (void)dealloc {
	[_progressBar release];
    [_activityIndicator release];
    [LoadingView release];
  //  [_xmlData release];
    [super dealloc];
}

@end
