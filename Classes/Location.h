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

#import <Foundation/Foundation.h>
#import "Station.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Location : NSObject <MKAnnotation>{
	NSString *name;
	NSMutableArray*openHours;
	NSMutableArray*stations;
    NSString * info;
    NSString * address;
    NSString * longitude;
    NSString *  latitude;
    //Trying to make it a regular annotation
    CLLocationCoordinate2D coordinate;
	NSString *currentSubTitle;
	NSString *currentTitle;
    NSMutableArray *places;
    UIImage *image;
    NSString * contactEmail;
    NSString *contactNumber;
    int locationId;
}

@property(nonatomic, retain) NSString * contactEmail;
@property(nonatomic, retain) NSString *contactNumber;
@property(nonatomic, retain) NSString * address;
@property(retain) NSMutableArray *places;
@property(nonatomic, retain) NSString *name; 
@property(nonatomic, retain) NSMutableArray *stations;
@property(nonatomic, retain) NSMutableArray *openHours;
@property(nonatomic, retain) NSString * longitude;
@property(nonatomic, retain) NSString *  latitude;
@property(nonatomic, retain) NSString *info;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *currentTitle;
@property (nonatomic, retain) NSString *currentSubTitle;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, assign)     int locationId;
- (NSString *)title;
- (NSString *)subtitle;
-(NSMutableArray *) getPlaces;
-(CLLocationCoordinate2D)getCoordinate;
-(void)addPlace:(Location *)place;
-(int)placesCount;

@end
