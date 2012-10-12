//
//  DetailViewController.m
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContentViewController.h"

#import "PostEditViewController.h"

@interface ContentViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)reply;
@end

@implementation ContentViewController

@synthesize isPad;
@synthesize contentText;
@synthesize swipeLeft;
@synthesize swipeRight;
@synthesize core = _core;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize board;
@synthesize postid;
@synthesize xid;

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	CFIndex count;
	if (isPad) {
		count = 80;
	} else {
		if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
			count = 80;
		} else {
			count = 40;
		}
	}
	self.contentText.converter.charCountInLine = count;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	CFIndex count;
	if (isPad) {
		count = 80;
	} else {
		if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
			count = 80;
		} else {
			count = 40;
		}
	}
	self.contentText.converter.charCountInLine = count;
	[self.contentText setNeedsDisplay];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = NSLocalizedString(@"Content", @"Content");
	}
	return self;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
	barButtonItem.title = NSLocalizedString(@"Board", @"Board");
	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
	self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	// Called when the view is shown again in the split view, invalidating the button and popover controller.
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	self.masterPopoverController = nil;
}

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender {
	if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
		// older / next post
		[self.core viewContentOfOlderPost];
	}
	if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
		// newer / prev post
		[self.core viewContentOfNewerPost];
	}
}

- (void)reply
{
	[self.navigationController pushViewController:self.core.postInput animated:YES];
	self.core.postInput.core = self.core;
	self.core.postInput.board = self.board;
	self.core.postInput.postid = self.postid;
	self.core.postInput.xid = self.xid;
	[self.core viewQuoteOfPost:self.postid onBoard:self.board WithXID:self.xid];
}

@end
