//
//  MasterViewController.m
//  iWell
//
//  Created by Wu Weiyi on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "LoginViewController.h"
#import "PostViewController.h"

@interface MasterViewController ()

- (void)changeMode;
- (void)connect;
- (void)post;
@end

@implementation MasterViewController

@synthesize isPad;
@synthesize isBoards;
@synthesize isFavorite;
@synthesize core = _core;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = NSLocalizedString(@"Master", @"Master");
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			self.clearsSelectionOnViewWillAppear = NO;
			self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
		}
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	if (isBoards) {
		self.navigationItem.title = isFavorite ? @"Favorite" : @"All Boards";
		UIBarButtonItem *changeButton = [[UIBarButtonItem alloc] initWithTitle:(isFavorite ? @"All Boards" : @"Favorite") style:UIBarButtonItemStylePlain target:self action:@selector(changeMode)];
		self.navigationItem.leftBarButtonItem = changeButton;
		UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStylePlain target:self action:@selector(connect)];
		self.navigationItem.rightBarButtonItem = connectButton;
		self.tableView.bounces = NO;
	} else {
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(post)];
		self.navigationItem.rightBarButtonItem = addButton;
		self.tableView.bounces = YES;
	}
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
	if (isBoards) {
		if (self.isFavorite) {
			[self.core listFavBoards];
		} else {
			[self.core listBoards];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (isBoards) {
		return 1;
	} else {
		return 3;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.isBoards) {
		return (NSInteger)[self.core boardsCount];
	} else {
		if (section == 1) {
			return (NSInteger)[self.core postsCountOnBoard:self.navigationItem.title];
		} else {
			return 1;
		}
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier;
	if (isBoards) {
		CellIdentifier = @"Board";
	} else {
		if (indexPath.section == 0) {
			CellIdentifier = @"Prev";
		} else if (indexPath.section == 1) {
			CellIdentifier = @"Post";
		} else if (indexPath.section == 2) {
			CellIdentifier = @"Next";
		}
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	if (self.isBoards) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		NSDictionary *dict = [self.core boardInfoAtIndex:(NSUInteger)indexPath.row];
		cell.textLabel.text = [dict objectForKey:@"name"];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@", [dict objectForKey:@"total"], [dict objectForKey:@"bm"]];
		if ([[dict objectForKey:@"read"] boolValue]) {
			cell.textLabel.font = [UIFont systemFontOfSize:16];
		} else {
			cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
			cell.backgroundColor = [UIColor lightGrayColor];
		}
	} else {
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		if (indexPath.section == 1) {
			NSDictionary *dict = [self.core postInfoAtIndex:(NSUInteger)indexPath.row onBoard:self.navigationItem.title];
			cell.textLabel.text = [dict objectForKey:@"title"];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@", [dict objectForKey:@"id"], [dict objectForKey:@"owner"]];
			if ([[dict objectForKey:@"read"] boolValue]) {
				cell.textLabel.font = [UIFont systemFontOfSize:16];
			} else {
				cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
				cell.backgroundColor = [UIColor lightGrayColor];
			}
		} else {
			cell.textLabel.textColor = [UIColor blueColor];
			cell.accessoryType = UITableViewCellAccessoryNone;
			if (indexPath.section == 0) {
				cell.textLabel.text = @"show newer 20 posts";
			} else if (indexPath.section == 2) {
				cell.textLabel.text = @"show older 20 posts";
			}
		}
	}
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the specified item to be editable.
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	// The table view should not be re-orderable.
	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (isBoards) {
		NSString *boardname = [self.core boardNameAtIndex:(NSUInteger)indexPath.row];
		MasterViewController *postsViewController = [self.core.postsOutputs valueForKey:boardname];
		if (postsViewController == nil) {
			if (isPad) {
				postsViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController_iPad" bundle:nil];
			} else {
				postsViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil];
			}
			postsViewController.core = self.core;
			postsViewController.isPad = self.isPad;
			postsViewController.isBoards = NO;
			postsViewController.navigationItem.title = boardname;
			[self.core.postsOutputs setValue:postsViewController forKey:boardname];
			[self.core listPostsOfBoard:boardname];
		}
		[self.navigationController pushViewController:postsViewController animated:YES];
	} else {
		if (indexPath.section == 1) {
			if (!isPad) {
				if (self.core.contentOutput == nil) {
					self.core.contentOutput = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil];
				}
				self.core.contentOutput.isPad = NO;
				[self.navigationController pushViewController:self.core.contentOutput animated:YES];
			} else {
				UIViewController *controller = [self.core.contentOutput.navigationController presentedViewController];
				if (controller != self.core.contentOutput) {
					[self.core.contentOutput.navigationController popViewControllerAnimated:YES];
				}
			}
			self.core.contentOutput.core = self.core;
			if (self.core.contentOutput.swipeLeft == nil) {
				self.core.contentOutput.swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self.core.contentOutput action:@selector(handleSwipe:)];
				self.core.contentOutput.swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
				[self.core.contentOutput.contentText addGestureRecognizer:self.core.contentOutput.swipeLeft];
			}
			if (self.core.contentOutput.swipeRight == nil) {
				self.core.contentOutput.swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self.core.contentOutput action:@selector(handleSwipe:)];
				self.core.contentOutput.swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
				[self.core.contentOutput.contentText addGestureRecognizer:self.core.contentOutput.swipeRight];
			}
			[self.core viewContentOfPost:[self.core postIDAtIndex:(NSUInteger)indexPath.row onBoard:self.navigationItem.title] onBoard:self.navigationItem.title];
		} else if (indexPath.section == 0) {
			[self.core listNewerPostsOfBoard:self.navigationItem.title];
		} else if (indexPath.section == 2) {
			[self.core listOlderPostsOfBoard:self.navigationItem.title];
		}
		[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void)changeMode
{
	if (self.isBoards) {
		self.isFavorite = !self.isFavorite;
		self.navigationItem.title = self.isFavorite ? @"Favorite" : @"All Boards" ;
		self.navigationItem.leftBarButtonItem.title = self.isFavorite ? @"All Boards" : @"Favorite";
		if (self.isFavorite) {
			[self.core listFavBoards];
		} else {
			[self.core listBoards];
		}
	}
}

- (void)connect
{
	if (isBoards) {
		if (self.core.loginInput == nil) {
			self.core.loginInput = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
		}
		self.core.loginInput.core = self.core;
		
		[self.navigationController pushViewController:self.core.loginInput animated:YES];
	}
}

- (void)post
{
	if (!isPad) {
		if (self.core.postInput == nil) {
			self.core.postInput = [[PostViewController alloc] initWithNibName:@"PostViewController_iPhone" bundle:nil];
		}
		[self.navigationController pushViewController:self.core.postInput animated:YES];
		self.core.postInput.core = self.core;
	} else {
		UIViewController *controller = [self.core.contentOutput.navigationController presentedViewController];
		if (controller == self.core.postInput) {
			return;
		}
		[self.core.contentOutput.navigationController pushViewController:self.core.postInput animated:YES];
	}
	self.core.postInput.board = self.navigationItem.title;
	self.core.postInput.postid = 0;
	self.core.postInput.xid = 0;
	self.core.postInput.titleInput.text = @"";
	NSMutableString *string = [NSMutableString stringWithString:@"\n\nSent from "];
	[string appendString:[UIDevice currentDevice].model];
	self.core.postInput.contentInput.text = string;
	self.core.postInput.contentInput.selectedRange = NSMakeRange(0, 0);
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.core.postInput action:@selector(post)];
	self.core.postInput.navigationItem.rightBarButtonItem = doneButton;
}

@end
