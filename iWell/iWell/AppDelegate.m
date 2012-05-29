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

#import "Core.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	Core *core = [[Core alloc] init];
	// Override point for customization after application launch.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil];
		self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
		self.window.rootViewController = self.navigationController;
		
		masterViewController.core = core;
		masterViewController.isPad = NO;
		masterViewController.isBoards = YES;
		masterViewController.isFavorite = YES;
		core.boardsOutput = masterViewController;
	} else {
		MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController_iPad" bundle:nil];
		UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
		
		DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" bundle:nil];
		UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
		
		self.splitViewController = [[UISplitViewController alloc] init];
		self.splitViewController.delegate = detailViewController;
		self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
		
		self.window.rootViewController = self.splitViewController;
		
		masterViewController.core = core;
		masterViewController.isPad = YES;
		masterViewController.isBoards = YES;
		masterViewController.isFavorite = YES;
		detailViewController.isPad = YES;
		core.boardsOutput = masterViewController;
		core.contentOutput = detailViewController;
		View *view = (View *)detailViewController.view;
		view.converter.charCountInLine = 80;
	}
	[self.window makeKeyAndVisible];
	return YES;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
