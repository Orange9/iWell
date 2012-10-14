//
//  DetailViewController.m
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContentViewController.h"

#import "PostEditViewController.h"

@implementation ContentView

@synthesize string;
@synthesize converter;

- (void)awakeFromNib
{
	self.contentMode = UIViewContentModeRedraw;
	converter = [StringConverter converter];
	NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(blink) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[super awakeFromNib];
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	dirtyRect.origin = self.contentOffset;
	self.contentSize = [converter draw:self.string InContext:context InRect:&dirtyRect];
	[super drawRect:dirtyRect];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self setNeedsDisplay];
}

- (void)blink
{
	self.converter.blink = !self.converter.blink;
	[self setNeedsDisplay];
}

@end

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

- (void)updateContent:(NSDictionary *)content
{
	self.contentText.string = [content valueForKey:@"content"];
	self.navigationItem.title = [content valueForKey:@"title"];
	[self.contentText setContentOffset:CGPointMake(0, 0) animated:NO];
	[self.contentText setNeedsDisplay];
	
	NSInteger pid = [(NSNumber *)[content valueForKey:@"id"] integerValue];
	if (pid == self.parentController.index) {
		self.xid = [(NSNumber *)[content valueForKey:@"xid"] integerValue];
		UIBarButtonItem *replyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(reply)];
		self.navigationItem.rightBarButtonItem = replyButton;
		[self.busyIndicator stopAnimating];
	}
}

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender {
	if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
		// older / next post
		[self.parentController selectPostWithOffset:-1];
	}
	if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
		// newer / prev post
		[self.parentController selectPostWithOffset:1];
	}
}

- (void)reply
{
	[self.navigationController pushViewController:self.core.postInput animated:YES];
	self.core.postInput.core = self.core;
	self.core.postInput.board = self.parentController.navigationItem.title;
	self.core.postInput.postid = self.parentController.index;
	self.core.postInput.xid = self.xid;
	self.core.postInput.navigationItem.rightBarButtonItem = nil;
	[self.core viewQuoteForController:self.core.postInput];
}

@end
