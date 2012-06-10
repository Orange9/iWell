//
//  AppDelegate.m
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "PostViewController.h"

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
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil];
		self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
		self.window.rootViewController = self.navigationController;
		
		masterViewController.core = self.core;
		masterViewController.isPad = NO;
		masterViewController.isBoards = YES;
		masterViewController.isFavorite = YES;
		self.core.boardsOutput = masterViewController;
		self.core.isOAuth = NO;
	} else {
		MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController_iPad" bundle:nil];
		UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
		
		DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" bundle:nil];
		UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
		
		self.splitViewController = [[UISplitViewController alloc] init];
		self.splitViewController.delegate = detailViewController;
		self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
		self.splitViewController.presentsWithGesture = NO;
		
		self.window.rootViewController = self.splitViewController;
		
		PostViewController *postViewController = [[PostViewController alloc] initWithNibName:@"PostViewController_iPad" bundle:nil];
		
		masterViewController.core = self.core;
		masterViewController.isPad = YES;
		masterViewController.isBoards = YES;
		masterViewController.isFavorite = YES;
		detailViewController.core = self.core;
		detailViewController.isPad = YES;
		postViewController.core = self.core;
		self.core.boardsOutput = masterViewController;
		self.core.contentOutput = detailViewController;
		self.core.postInput = postViewController;
		self.core.isOAuth = NO;
		View *view = (View *)detailViewController.view;
		view.converter.charCountInLine = 80;
	}
	[self.window makeKeyAndVisible];
	return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	NSString *token = [[url query] substringFromIndex:5];
	self.core.isOAuth = YES;
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
