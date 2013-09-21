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
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import <iAd/iAd.h>
#import "NautilusMarketXMLViewController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, ADBannerViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, DownloadCompleteDelegate, MFMailComposeViewControllerDelegate>
{
    MKMapView *mapView;
  
    //  DetailViewController *detailViewController;
    NSMutableArray *mapAnnotations;
    NSMutableArray* locationsToFilter;
    NSMutableArray* locationsToDisplay;
    NSMutableArray*pickerLocations;
    CLLocationDegrees zoomLevel;
    IBOutlet UIToolbar *toolbar;
    IBOutlet ADBannerView *banner;
    IBOutlet UITextView *phoneTextView;

    IBOutlet UISegmentedControl * control;
    CLLocationManager *locationManager;
    BOOL updated;
    IBOutlet UIPickerView *_pickerView;
    IBOutlet UIView *pickerLocationsView;
    IBOutlet UIView *infoView;
    NautilusMarketXMLViewController *c;
    
    //Info
    IBOutlet UILabel *phoneLabel;
    IBOutlet UILabel *emailLabel;
    IBOutlet UIButton *phoneButton;
    IBOutlet UIButton *emailButton;
    IBOutlet UITextView *description;
    
}
- (IBAction)openLink:(id)sender;
- (IBAction)openFacebook:(id)sender;
                                    
- (IBAction)emailAction:(id)sender;
- (IBAction)callAction:(id)sender;
- (IBAction)showPickerDetails:(id)sender;
- (IBAction)hidePicker:(id)sender;
- (IBAction)showPickerLocations:(id)sender;
-(void)filterAnnotations:(NSArray *)placesToFilter;
-(void) showAllLocations;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *locationsToFilter;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet ADBannerView *banner;


-(IBAction) segmentedControlSwitched:(id)sender;
-(IBAction) done;
-(IBAction) gotoLocation;
-(IBAction) showCurrentLocation;
-(IBAction) updateInformation;
-(void)updateDescriptions;
-(IBAction) showInfo;
-(IBAction) done;
-(void)layoutForCurrentOrientation:(BOOL)animated;

@end
