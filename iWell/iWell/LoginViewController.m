//
//  LoginViewController.m
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
{
	CGRect keyboardBounds;
}

@end

@implementation LoginViewController

@synthesize addressInput;
@synthesize usernameInput;
@synthesize passwordInput;
@synthesize core = _core;

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
	// Do any additional setup after loading the view from its nib.
	self.addressInput.text = [self.core address];
	self.usernameInput.text = [self.core username];
	self.passwordInput.text = [self.core password];
	self.addressInput.delegate = self;
	self.usernameInput.delegate = self;
	self.passwordInput.delegate = self;
	//self.navigationItem.hidesBackButton = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (IBAction)connect:(id)sender
{
	self.core.isOAuth = NO;
	[self.core connect:self.addressInput.text withUsername:self.usernameInput.text Password:self.passwordInput.text];
}

- (IBAction)OAuth:(id)sender
{
	[self.core OAuth:self.addressInput.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.addressInput) {
		[self.usernameInput becomeFirstResponder];
	} else if (textField == self.usernameInput) {
		[self.passwordInput becomeFirstResponder];
	} else if (textField == self.passwordInput) {
		[self connect:self];
	}
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	UIScrollView *scrollView = (UIScrollView *)self.view;
	scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + keyboardBounds.size.height);
	CGFloat offset = textField.frame.origin.y - (self.view.frame.size.height - keyboardBounds.size.height - textField.frame.size.height) / 2;
	if (offset < 0) {
		offset = 0;
	}
	[scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
}

- (void)keyboardNotification:(NSNotification*)notification
{
	NSDictionary *userInfo = [notification userInfo];  
	NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];  
	[keyboardBoundsValue getValue:&keyboardBounds];
}

@end
