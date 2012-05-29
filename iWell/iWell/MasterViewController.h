//
//  MasterViewController.h
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Core.h"

@interface MasterViewController : UITableViewController

@property (assign, nonatomic) BOOL isPad; // pad or phone

@property (assign, nonatomic) BOOL isBoards; // borads or posts
@property (assign, nonatomic) BOOL isFavorite; // favorite or all

@property (retain, nonatomic) Core *core;

@end
