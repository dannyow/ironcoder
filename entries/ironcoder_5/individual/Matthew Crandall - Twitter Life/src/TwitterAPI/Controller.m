//
//  Controller.m
//  TwitterAPI
//
//  Created by Matthew Crandall on 3/31/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com . All rights reserved.
//

#import "Controller.h"
#import "MCTwitter.h"
#import "TwitterView.h"

@implementation Controller

- (void)getTwitterInfo:(id)sender {

	TwitterRemoteCall rc = MCTwitter_publicTimeline;
	
	switch ([_selector indexOfSelectedItem]) {
		case 0:
			rc = MCTwitter_publicTimeline;
			break;
		case 1:
			rc = MCTwitter_friendsTimeline;
			break;
		case 2:
			rc = MCTwitter_friends;
			break;
		case 3:
			rc = MCTwitter_followers;
			break;
		default:
			rc = MCTwitter_publicTimeline;
			break;
	}

	MCTwitter *callingObject = [[MCTwitter alloc] initWithLogin:@"dummy@mchotsoftware.com" password:@"ironcoder" forCall:rc];
	[callingObject setDelegate:self];
	[callingObject request];
}

- (void)twitter:(MCTwitter *)twitter didReceiveResponse:(NSArray *)response {
	[_view receivedResponse:response];
}


@end
