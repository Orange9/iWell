//
//  BoardsViewController.m
//  iWell
//
//  Created by Wu Weiyi on 10/9/12.
//
//

#import "BoardsViewController.h"
#import "PostsViewController.h"

@interface BoardsViewController ()

- (void)changeMode;
- (void)connect;

@end

@implementation BoardsViewController

@synthesize postsViewControllers = _postsViewControllers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		 self.postsViewControllers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.navigationItem.title = (self.type == LIST_FAV) ? @"Favorite" : @"All Boards";
	UIBarButtonItem *changeButton = [[UIBarButtonItem alloc] initWithTitle:((self.type == LIST_FAV) ? @"All Boards" : @"Favorite") style:UIBarButtonItemStylePlain target:self action:@selector(changeMode)];
	self.navigationItem.leftBarButtonItem = changeButton;
	UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStylePlain target:self action:@selector(connect)];
	self.navigationItem.rightBarButtonItem = connectButton;
	self.tableView.bounces = NO;
}

- (void)viewWillAppear:(BOOL)animated {
	if (self.type == LIST_FAV) {
		[self.core listFavBoards];
		[self.busyIndicator startAnimating];
	} else if (self.type == LIST_BOARD) {
		[self.core listBoards];
		[self.busyIndicator startAnimating];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return (NSInteger)[self.core boardsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = @"Title";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	NSDictionary *dict = [self.core boardInfoAtIndex:(NSUInteger)indexPath.row];
	cell.textLabel.text = [dict objectForKey:@"name"];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@", [dict objectForKey:@"total"], [dict objectForKey:@"bm"]];
	if ([[dict objectForKey:@"read"] boolValue]) {
		cell.textLabel.font = [UIFont systemFontOfSize:16];
	} else {
		cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
		cell.backgroundColor = [UIColor lightGrayColor];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *boardname = [self.core boardNameAtIndex:(NSUInteger)indexPath.row];
	PostsViewController *postsViewController = [self.postsViewControllers valueForKey:boardname];
	if (postsViewController == nil) {
		if (self.isPad) {
			postsViewController = [[PostsViewController alloc] initWithNibName:@"ListViewController_iPad" bundle:nil];
		} else {
			postsViewController = [[PostsViewController alloc] initWithNibName:@"ListViewController_iPhone" bundle:nil];
		}
		postsViewController.core = self.core;
		postsViewController.isPad = self.isPad;
		postsViewController.navigationItem.title = boardname;
		[self.postsViewControllers setValue:postsViewController forKey:boardname];
		[self.core listPostsOfBoard:boardname];
	}
	[self.navigationController pushViewController:postsViewController animated:YES];
}

- (void)changeMode
{
	if (self.type == LIST_FAV) {
		self.type = LIST_BOARD;
		self.navigationItem.title = @"All Boards";
		self.navigationItem.leftBarButtonItem.title = @"Favorite";
		[self.core listBoards];
	} else if (self.type == LIST_BOARD)	{
		self.type = LIST_FAV;
		self.navigationItem.title = @"Favorite";
		self.navigationItem.leftBarButtonItem.title = @"All Boards";
		[self.core listFavBoards];
	}
}

- (void)connect
{
	if (self.type == LIST_FAV || self.type == LIST_BOARD) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Address" message:@"Please enter server address:" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
		alert.alertViewStyle = UIAlertViewStylePlainTextInput;
		UITextField *text = [alert textFieldAtIndex:0];
		text.keyboardType = UIKeyboardTypeURL;
		text.text = self.core.address;
		text.placeholder = @"https://server:port";
		[alert show];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	UITextField *text = [alertView textFieldAtIndex:0];
	[self.core OAuth:text.text];
}

@end
