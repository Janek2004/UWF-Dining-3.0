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

#import "MealPeriod.h"


@implementation MealPeriod
@synthesize name;
@synthesize menuItems, openHours; 

-(id)init{
	if((self=[super init]))
	{
		menuItems=[[NSMutableArray alloc]initWithCapacity:0];	
		openHours=[[NSMutableArray alloc]initWithCapacity:0];	

	}
	return self;
}



-(void) dealloc{
	[name release];
	[menuItems release];
	[openHours release];
	self.name=nil;
	self.menuItems=nil;
	self.openHours=nil;
	[super dealloc];
}

@end
