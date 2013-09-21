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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <iAd/iAd.h>
@class Station;
@class Location;
#import "NautilusMarketXMLViewController.h"

@interface StationsTable : UIViewController <UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate, MFMailComposeViewControllerDelegate, DownloadCompleteDelegate>{
	NSMutableArray * stations;
    Station *station;
    Location * location;
    IBOutlet UISegmentedControl *MenuSegmentedControl;
    IBOutlet UITableView *table;
    int mode;
    NSString * currentKey;
    IBOutlet UIToolbar *toolbar;
    IBOutlet ADBannerView *bannerTable;
    IBOutlet UIView *infoView;
    IBOutlet UILabel *phoneLabel;
    IBOutlet UILabel *emailLabel;
    NSMutableDictionary * menu;
    NSMutableArray *mutableMeals;
 
    IBOutlet UITextView *description;
    IBOutlet UILabel *locationNameInfo;
    IBOutlet UILabel *locationName;
    IBOutlet UILabel *locationAddress;
    IBOutlet UILabel *openFrom;    
    IBOutlet UIButton *emailButton;
    IBOutlet UIButton *phoneButton;
    IBOutlet UILabel *MenuSubjectToChange;
    NSUserDefaults * defaults;
    
    
}

@property(nonatomic, retain) NSMutableArray *stations;
@property(nonatomic, retain) Station *station;
@property(nonatomic, retain) Location * location;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet ADBannerView *bannerTable;

-(void)layoutForCurrentOrientation:(BOOL)animated;
-(IBAction)dismiss;
-(IBAction)showInfo;
-(IBAction)done;
-(IBAction)mealTypeChanged:(id)sender;
-(void)prepareMenu;
-(void) showHoursAndAnAddress;
-(IBAction) emailAction:(id)sender;
-(IBAction) callAction:(id)sender;
-(IBAction) updateInformation;

@end
