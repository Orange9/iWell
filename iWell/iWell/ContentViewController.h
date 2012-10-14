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

@interface ContentViewController : UIViewController <UISplitViewControllerDelegate>

@property (assign, nonatomic) BOOL isPad;

@property (strong, nonatomic) IBOutlet ContentView *contentText;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *busyIndicator;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeLeft;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRight;

@property (retain, nonatomic) PostsViewController *parentController;

@property (retain, nonatomic) Core *core;

@property (assign, nonatomic) NSUInteger xid;

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender;
- (void)updateContent:(NSDictionary *)content;

@end
