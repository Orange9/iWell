//
//  LoginViewController.h
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Core.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *addressInput;
@property (strong, nonatomic) IBOutlet UITextField *usernameInput;
@property (strong, nonatomic) IBOutlet UITextField *passwordInput;

@property (retain, nonatomic) Core *core;

- (IBAction)connect:(id)sender;

@end
