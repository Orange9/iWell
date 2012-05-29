//
//  LoginViewController.m
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

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
	self.navigationItem.hidesBackButton = YES;
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


- (IBAction)connect:(id)sender {
	[self.core connect:self.addressInput.text withUsername:self.usernameInput.text Password:self.passwordInput.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.addressInput) {
		[self.usernameInput becomeFirstResponder];
	} else if (textField == self.usernameInput) {
		[self.passwordInput becomeFirstResponder];
	} else if (textField == self.passwordInput) {
		[self connect:self];
	}
	return YES;
}

@end
