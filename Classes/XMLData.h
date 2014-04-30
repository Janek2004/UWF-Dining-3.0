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
#import "Location.h"

#import "GDataXMLNode.h"

@interface XMLData : NSObject {
	NSString *message;
	NSString *date;
    NSString *generalInfo;
    NSString * contactEmail;
    NSString * contactNumber;
	NSMutableArray * locationsArray;
	NSMutableArray *locationsInfoArray;
    NSMutableDictionary * extraInfo;
  //  GDataXMLDocument *doc;
    int locationId;
}
@property(nonatomic, retain) GDataXMLDocument *doc;
@property(nonatomic, retain) NSMutableArray * locationsArray;
@property(nonatomic, retain) NSMutableArray *locationsInfoArray;
@property(nonatomic, retain) NSString *generalInfo;
@property(nonatomic, retain) NSString * contactEmail;
@property(nonatomic, retain) NSString * contactNumber;
@property(nonatomic, retain) NSMutableDictionary * extraInfo;
@property(nonatomic, retain) 	NSString *date;
//-(void) parsing;
//-(void) parsingAdditionalData;
/**
 *  Downloading, parsing and merging data.
 *
 *  @param successBlock executed whenever operation is completed
 *  @param errorBlock   exuecuted whenever operation is interreptued
 */
-(void) startDownloadingWithCompletionBlock:(void(^)())successBlock andError: (void(^)(NSError * error))errorBlock;



@end
