/* SPController */

#import <Cocoa/Cocoa.h>

#import "SPTemplate.h"

#import "SimpleHTTPConnection.h"
#import "SimpleHTTPServer.h"
#import <stdio.h>
#import <string.h>
#import <sys/socket.h>
#include <arpa/inet.h>


@interface SPController : NSObject
{
    IBOutlet NSMenu *menu;
	
	NSStatusItem *statusItem;
	
	SimpleHTTPServer *server;
	
	SPTemplate *template;
}
- (IBAction)takePicture:(id)sender;

- (void)awakeFromNib;
- (void)_startWebServer;
- (void)setServer:(SimpleHTTPServer *)sv;
- (SimpleHTTPServer *)server;
- (void)processURL:(NSURL *)path connection:(SimpleHTTPConnection *)connection;
- (void)_startPictureTaking;

@end
