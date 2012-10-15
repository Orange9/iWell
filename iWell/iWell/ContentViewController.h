//
//  DetailViewController.h
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Core.h"
#import "PostsViewController.h"
#import "StringConverter.h"

@interface ContentView : UIScrollView <UIScrollViewDelegate> {
	
}

@property (strong, atomic) NSString *string;
@property (strong, nonatomic) StringConverter *converter;

- (void)blink;

@end

enum CONTENT_TYPE {
	CONTENT_SHOW_POST,
	CONTENT_SHOW_DIGEST,
};

@interface ContentViewController : UIViewController <UISplitViewControllerDelegate>

@property (assign, nonatomic) BOOL isPad;

@property (strong, nonatomic) IBOutlet ContentView *contentText;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *busyIndicator;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeLeft;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRight;

@property (retain, nonatomic) PostsViewController *postsViewController;
@property (retain, nonatomic) DigestsViewController *digestsViewController;

@property (assign, nonatomic) enum CONTENT_TYPE type;

@property (retain, nonatomic) Core *core;

@property (assign, nonatomic) NSInteger xid;

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender;
- (void)updateContent:(NSDictionary *)content;
- (void)updateDigest:(NSDictionary *)content;

@end
