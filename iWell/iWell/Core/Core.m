//
//  Core_Pad.m
//  iWell-Pad
//
//  Created by Wu Weiyi on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Core.h"

#import "BoardsViewController.h"
#import "PostsViewController.h"
#import "DigestsViewController.h"
#import "ContentViewController.h"
#import "PostEditViewController.h"

@interface Core ()
@property (strong, nonatomic) BBSCore *bbsCore;
@property (strong, nonatomic) PreferenceStorage *preferenceStorage;

- (void)saveAddress:(NSString *)address;
- (void)saveToken:(NSString *)token;
- (void)alert:(NSString *)message;

@end

@implementation Core

@synthesize bbsCore = _bbsCore;
@synthesize preferenceStorage = _preferenceStorage;
@synthesize boardsOutput = _boardsOutput;
@synthesize contentOutput = _contentOutput;
@synthesize postInput = _postInput;

#pragma mark - Public Methods

- (id)init
{
	self.preferenceStorage = [[PreferenceStorage alloc] init];
	
	self.bbsCore = [[BBSCore alloc] init];
	self.bbsCore.delegate = self;
	self.bbsCore.baseURL = [NSURL URLWithString:[self.preferenceStorage valueForKey:@"address"]];
	self.bbsCore.sessionToken = [self.preferenceStorage valueForKey:@"token"];
	
	self.boardsOutput = nil;
	self.contentOutput = nil;
	
	//[self.bbsCore connectWithStage:BBS_OAUTH_VERIFY];
	return self;
}

- (NSString *)address
{
	return [self.bbsCore.baseURL absoluteString];
}

- (void)OAuth:(NSString *)address
{
	[self saveAddress:address];
	[self.bbsCore OAuth];
}

- (void)connectWithToken:(NSString *)token
{
	self.bbsCore.authorizationToken = token;
	[self.boardsOutput.busyIndicator startAnimating];
	[self.bbsCore connectWithStage:BBS_OAUTH_SESSION];
}

- (void)resume
{
	if (self.bbsCore.sessionToken.length) {
		[self.bbsCore connectWithStage:BBS_OAUTH_VERIFY];
	} else {
		[self.boardsOutput performSelectorOnMainThread:@selector(connect) withObject:nil waitUntilDone:YES];
	}
}

- (void)listBoardsForController:(BoardsViewController *)controller
{
	[self.bbsCore listBoardsInRange:NSMakeRange(1, 1000) ForController:controller];
}

- (void)listFavBoardsForController:(BoardsViewController *)controller
{
	[self.bbsCore listFavBoardsInRange:NSMakeRange(0, 0) ForController:controller];
}

- (void)listPostsForController:(PostsViewController *)controller
{
	[self.bbsCore listPostsInRange:NSMakeRange(0, 20) OnBoard:controller.navigationItem.title ForController:controller];
}

- (void)listPostsFrom:(NSInteger)startid To:(NSInteger)endid ForController:(PostsViewController *)controller
{
	[self.bbsCore listPostsInRange:NSMakeRange((NSUInteger)startid, (NSUInteger)(endid - startid + 1)) OnBoard:controller.navigationItem.title ForController:controller];
}

- (void)listDigestsForController:(DigestsViewController *)controller
{
	[self.bbsCore listDigestInRange:NSMakeRange(0, 0) OnBoard:controller.board WithRoute:controller.route ForController:controller];
}

- (void)viewContentForController:(ContentViewController *)controller
{
	controller.type = CONTENT_SHOW_POST;
	[self.bbsCore viewContentOfPost:(NSUInteger)controller.postsViewController.index OnBoard:controller.postsViewController.navigationItem.title ForController:controller];
}

- (void)viewDigestForController:(ContentViewController *)controller
{
	controller.type = CONTENT_SHOW_DIGEST;
	NSString *route = [NSString stringWithFormat:@"%@-%d", controller.digestsViewController.route, controller.digestsViewController.index + 1];
	[self.bbsCore viewDigestWithRoute:route OnBoard:controller.digestsViewController.board ForController:controller];
}

- (void)viewQuoteForController:(PostEditViewController *)controller
{
	[self.bbsCore viewQuoteOfPost:(NSUInteger)controller.postid OnBoard:controller.board WithXID:(NSUInteger)controller.xid ForController:controller];
}

- (void)postForController:(PostEditViewController *)controller
{
	[self.bbsCore post:controller.contentInput.text WithTitle:controller.titleInput.text OnBoard:controller.board WithID:(NSUInteger)controller.postid WithXID:(NSUInteger)controller.xid ForController:controller];
}

#pragma mark - Private Methods

- (void)saveAddress:(NSString *)address
{
	NSURL *url = [NSURL URLWithString:address];
	if (![[self.bbsCore.baseURL absoluteString] isEqualToString:[url absoluteString]]) {
		self.bbsCore.baseURL = url;
	}
	[self.preferenceStorage setValue:address forKey:@"address"];
}

- (void)saveToken:(NSString *)token
{
	if (![self.bbsCore.sessionToken isEqualToString:token]) {
		self.bbsCore.sessionToken = token;
	}
	[self.preferenceStorage setValue:token forKey:@"token"];
}

- (void)alert:(NSString *)message
{
	[[[UIAlertView alloc] initWithTitle:@"Error!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - Delegate Methods

- (void)online:(NSString *)token
{
	[self.boardsOutput viewWillAppear:YES];
	[self.preferenceStorage setValue:token forKey:@"token"];
}

- (void)printContent:(NSString *)content
{
	[self performSelectorOnMainThread:@selector(alert:) withObject:content waitUntilDone:YES];
}

- (void)showContent:(NSDictionary *)content OnBoard:(NSString *)board ForController:(id)controller
{
	ContentViewController *c = controller;
	if (c.type == CONTENT_SHOW_POST && [c.postsViewController.navigationItem.title isEqualToString:board]) {
		[controller performSelectorOnMainThread:@selector(updateContent:) withObject:content waitUntilDone:YES];
	}
}

- (void)showDigest:(NSDictionary *)content WithRoute:(NSString *)route OnBoard:(NSString *)board ForController:(id)controller
{
	ContentViewController *c = controller;
	NSString *r = [NSString stringWithFormat:@"%@-%d", c.digestsViewController.route, c.digestsViewController.index + 1];
	if (c.type == CONTENT_SHOW_DIGEST && [r isEqualToString:route] && [c.digestsViewController.board isEqualToString:board]) {
		[controller performSelectorOnMainThread:@selector(updateDigest:) withObject:content waitUntilDone:YES];
	}
}

- (void)showQuote:(NSDictionary *)content OnBoard:(NSString *)board WithID:(NSUInteger)postid WithXID:(NSUInteger)xid ForController:(id)controller
{
	PostEditViewController *c = controller;
	if (c.xid == xid && c.postid == postid && [c.board isEqualToString:board]) {
		[controller performSelectorOnMainThread:@selector(updateQuote:) withObject:content waitUntilDone:YES];
	}
}

- (void)showDigests:(NSArray *)digests ForController:(id)controller
{
	[controller performSelectorOnMainThread:@selector(updateDigests:) withObject:digests waitUntilDone:YES];
}

- (void)showPosts:(NSArray *)posts ForController:(id)controller
{
	[controller performSelectorOnMainThread:@selector(updatePosts:) withObject:posts waitUntilDone:YES];
}

- (void)showBoards:(NSArray *)boards ForController:(id)controller
{
	[controller performSelectorOnMainThread:@selector(updateBoards:) withObject:boards waitUntilDone:YES];
}

@end

