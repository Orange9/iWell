//
//  PostViewController.m
//  iWell
//
//  Created by Wu Weiyi on 10/9/12.
//
//

#import "PostsViewController.h"

#import "ContentViewController.h"
#import "PostEditViewController.h"

@interface PostsViewController ()

- (void)post;

@end

@implementation PostsViewController

@synthesize digestViewController = _digestViewController;

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
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(post)];
	self.navigationItem.rightBarButtonItem = addButton;
	self.tableView.bounces = NO;
	[self.busyIndicator startAnimating];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 2) {
		return (NSInteger)[self.core postsCountOnBoard:self.navigationItem.title];
	} else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier;
	if (indexPath.section == 0) {
		CellIdentifier = @"Digest";
	} else if (indexPath.section == 1) {
		CellIdentifier = @"Prev";
	} else if (indexPath.section == 2) {
		CellIdentifier = @"Title";
	} else if (indexPath.section == 3) {
		CellIdentifier = @"Next";
	}
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (indexPath.section == 2) {
		// normal
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			if (self.isPad) {
				cell.accessoryType = UITableViewCellAccessoryNone;
			} else {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
		NSDictionary *dict = [self.core postInfoAtIndex:(NSUInteger)indexPath.row onBoard:self.navigationItem.title];
		cell.textLabel.text = [dict objectForKey:@"title"];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@", [dict objectForKey:@"id"], [dict objectForKey:@"owner"]];
		if ([[dict objectForKey:@"read"] boolValue]) {
			cell.textLabel.font = [UIFont systemFontOfSize:16];
		} else {
			cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
			cell.backgroundColor = [UIColor lightGrayColor];
		}
	} else if (indexPath.section == 0) {
		// digest
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.textLabel.text = @"Digest";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	} else {
		// prev / next
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.textLabel.textColor = [UIColor blueColor];
			cell.accessoryType = UITableViewCellAccessoryNone;
			if (indexPath.section == 1) {
				cell.textLabel.text = @"show newer 20 posts";
			} else if (indexPath.section == 3) {
				cell.textLabel.text = @"show older 20 posts";
			}
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		// digest
		NSString *boardname = [self.core boardNameAtIndex:(NSUInteger)indexPath.row];
		if (self.digestViewController == nil) {
			if (self.isPad) {
				self.digestViewController = [[DigestsViewController alloc] initWithNibName:@"ListViewController_iPad" bundle:nil];
			} else {
				self.digestViewController = [[DigestsViewController alloc] initWithNibName:@"ListViewController_iPhone" bundle:nil];
			}
			self.digestViewController.core = self.core;
			self.digestViewController.isPad = self.isPad;
			self.digestViewController.navigationItem.title = boardname;
			[self.digestViewController.busyIndicator startAnimating];
		}
		[self.navigationController pushViewController:self.digestViewController animated:YES];
		// TODO: load digest
	} else if (indexPath.section == 2) {
		// normal post title
		if (!self.isPad) {
			[self.navigationController pushViewController:self.core.contentOutput animated:YES];
		} else {
			UIViewController *controller = [self.core.contentOutput.navigationController presentedViewController];
			if (controller != self.core.contentOutput) {
				[self.core.contentOutput.navigationController popViewControllerAnimated:YES];
			}
		}
		[self.core viewContentOfPost:[self.core postIDAtIndex:(NSUInteger)indexPath.row onBoard:self.navigationItem.title] onBoard:self.navigationItem.title];
	} else if (indexPath.section == 1) {
		// previous posts
		[self.core listNewerPostsOfBoard:self.navigationItem.title];
		[self.busyIndicator startAnimating];
	} else if (indexPath.section == 3) {
		// next posts
		[self.core listOlderPostsOfBoard:self.navigationItem.title];
		[self.busyIndicator startAnimating];
	}
	[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)post
{
	if (self.isPad) {
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
