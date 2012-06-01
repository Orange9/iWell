//
//  DetailViewController.h
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Core.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (assign, nonatomic) BOOL isPad;

@property (strong, nonatomic) IBOutlet View *contentText;

@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeft;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeRight;

@property (retain, nonatomic) Core *core;

@property (strong, nonatomic) NSString *board;
@property (assign, nonatomic) NSUInteger postid;
@property (assign, nonatomic) NSUInteger xid;

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender;

@end
