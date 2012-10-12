//
//  AppDelegate.m
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "BoardsViewController.h"

#import "ContentViewController.h"

#import "PostEditViewController.h"

#import "Core.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;
@synthesize core = _core;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.core = [[Core alloc] init];
	// Override point for customization after application launch.
	UIDevice *device = [UIDevice currentDevice];
	if ([device userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		BoardsViewController *boardsViewController = [[BoardsViewController alloc] initWithNibName:@"ListViewController_iPhone" bundle:nil];
		self.navigationController = [[UINavigationController alloc] initWithRootViewController:boardsViewController];
		self.window.rootViewController = self.navigationController;
		
		ContentViewController *contentViewController = [[ContentViewController alloc] initWithNibName:@"ContentViewController_iPhone" bundle:nil];
		PostEditViewController *postEditViewController = [[PostEditViewController alloc] initWithNibName:@"PostEditViewController_iPhone" bundle:nil];
		
		boardsViewController.core = self.core;
		boardsViewController.isPad = NO;
		boardsViewController.type = LIST_FAV;
		contentViewController.core = self.core;
		contentViewController.isPad = NO;
		postEditViewController.core = self.core;
		self.core.boardsOutput = boardsViewController;
		self.core.contentOutput = contentViewController;
		self.core.postInput = postEditViewController;
	} else {
		BoardsViewController *boardsViewController = [[BoardsViewController alloc] initWithNibName:@"ListViewController_iPad" bundle:nil];
		UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:boardsViewController];
		
		ContentViewController *contentViewController = [[ContentViewController alloc] initWithNibName:@"ContentViewController_iPad" bundle:nil];
		UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:contentViewController];
		
		self.splitViewController = [[UISplitViewController alloc] init];
		self.splitViewController.delegate = contentViewController;
		self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
		self.splitViewController.presentsWithGesture = NO;
		
		self.window.rootViewController = self.splitViewController;
		
		PostEditViewController *postEditViewController = [[PostEditViewController alloc] initWithNibName:@"PostEditViewController_iPad" bundle:nil];
		
		boardsViewController.core = self.core;
		boardsViewController.isPad = YES;
		boardsViewController.type = LIST_FAV;
		contentViewController.core = self.core;
		contentViewController.isPad = YES;
		postEditViewController.core = self.core;
		self.core.boardsOutput = boardsViewController;
		self.core.contentOutput = contentViewController;
		self.core.postInput = postEditViewController;
		View *view = (View *)contentViewController.view;
		view.converter.charCountInLine = 80;
	}
	if ([launchOptions valueForKey:UIApplicationLaunchOptionsURLKey] == nil) {
		[self.core resume];
	}
	[self.window makeKeyAndVisible];
	return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	NSString *token = [[url query] substringFromIndex:5];
	[self.core connectWithToken:token];
	return YES;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
