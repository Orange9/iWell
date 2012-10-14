//
//  PostViewController.h
//  iWell
//
//  Created by Wu Weiyi on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Core.h"

@interface PostEditViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *titleInput;
@property (strong, nonatomic) IBOutlet UITextView *contentInput;

@property (retain, nonatomic) Core *core;

@property (strong, nonatomic) NSString *board;
@property (assign, nonatomic) NSUInteger postid;
@property (assign, nonatomic) NSUInteger xid;

- (void)updateQuote:(NSDictionary *)quote;
- (void)post;

@end
