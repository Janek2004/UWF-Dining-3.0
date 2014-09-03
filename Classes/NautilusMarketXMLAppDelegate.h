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

@class UpdaterViewController;
@class MapViewController;
@interface NautilusMarketXMLAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UpdaterViewController *viewController;
    MapViewController *_viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UpdaterViewController *viewController;
@property (nonatomic, retain) IBOutlet  MapViewController *_viewController;

@end

