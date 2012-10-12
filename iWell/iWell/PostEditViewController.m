//
//  PostViewController.m
//  iWell
//
//  Created by Wu Weiyi on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostEditViewController.h"

@interface PostEditViewController ()
{
	id textInput;
}

@end

@implementation PostEditViewController
@synthesize titleInput;
@synthesize contentInput;
@synthesize core = _core;
@synthesize board;
@synthesize postid;
@synthesize xid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)post
{
	[self.core post:self.contentInput.text WithTitle:self.titleInput.text onBoard:self.board WithID:self.postid WithXID:self.xid];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	textInput = textField;
	UIScrollView *scrollView = (UIScrollView *)self.view;
	[scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textInput == textField) {
		textInput = nil;
	}
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	textInput = textView;
	UIScrollView *scrollView = (UIScrollView *)self.view;
	[scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y) animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if (textInput == textView) {
		textInput = nil;
	}
}

- (void)textViewDidChange:(UITextView *)textView
{
	[textView scrollRangeToVisible:textView.selectedRange];
	UIScrollView *scrollView = (UIScrollView *)self.view;
	[scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y) animated:YES];
}

- (void)keyboardWillShowNotification:(NSNotification*)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
	CGRect keyboardBounds;
	[keyboardBoundsValue getValue:&keyboardBounds];
	CGFloat keyboardHeight;
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		keyboardHeight = keyboardBounds.size.width;
	} else {
		keyboardHeight = keyboardBounds.size.height;
	}
	
	UIScrollView *scrollView = (UIScrollView *)self.view;
	CGRect viewFrame = scrollView.bounds;
	scrollView.contentSize = CGSizeMake(viewFrame.size.width, viewFrame.size.height + keyboardHeight);
	CGRect frame = self.contentInput.frame;
	frame.size.height = viewFrame.size.height - keyboardHeight;
	[self.contentInput setFrame:frame];
}

- (void)keyboardWillHideNotification:(NSNotification*)notification
{
	UIScrollView *scrollView = (UIScrollView *)self.view;
	CGRect viewFrame = scrollView.bounds;
	scrollView.contentSize = CGSizeMake(viewFrame.size.width, viewFrame.size.height);
	CGRect frame = self.contentInput.frame;
	frame.size.height = viewFrame.size.height - frame.origin.y;
	[self.contentInput setFrame:frame];
}

@end
