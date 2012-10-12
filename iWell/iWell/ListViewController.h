//
//  MasterViewController.h
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Core.h"

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *busyIndicator;

@property (assign, nonatomic) BOOL isPad; // pad or phone

@property (retain, nonatomic) Core *core;

@end
