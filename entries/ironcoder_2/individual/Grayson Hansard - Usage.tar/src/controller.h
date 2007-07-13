/* controller */

#import <Cocoa/Cocoa.h>
#include <sys/sysctl.h>
#include <unistd.h>
#include <time.h>
#include <pwd.h>

typedef struct {
	NSTimeInterval highestUptime;
	NSTimeInterval uptime;
	double rowHeight;
} PatternInfo;

@interface controller : NSObject
{
	NSArray *_processes;
	IBOutlet NSTableView *tableView;
	IBOutlet NSButton *userButton;
	float rowHeight;
}

-(NSArray *)processes;
-(void)setProcesses:(NSArray *)processes;

-(NSMutableDictionary *)parseProcess:(NSString *)process;

-(IBAction)changeSize:(id)sender;

@end
