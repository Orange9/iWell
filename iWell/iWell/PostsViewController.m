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

@property (strong, nonatomic) NSMutableArray *posts;
//	[
//		{
//			"posttime": <time: post time>,
//			"attachflag": <int: unknown>,
//			"read": <Boolean: Post read>,
//			"title": <string: Post title>,
//			"attachment": <int: Attachment count>,
//			"owner": <string: Poster userid>,
//			"id": <int: Post id>,
//			"xid": <int: unique post ID>,
//			"thread": <int: thread ID>,
//			"reply_to": <int: ID of the post this post replied to>,
//			"size": <int: post size>,
//			"flags": [<string: one flag>, ...],
//		}
//	]

@property (assign, nonatomic) NSInteger offset;

- (void)post;

@end

@implementation PostsViewController

@synthesize digestsViewController = _digestViewController;
@synthesize posts = _posts;
@synthesize index = _index;
@synthesize offset = _offset;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		 self.posts = [NSMutableArray array];
		 self.index = -1;
		 self.offset = 0;
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
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.core listPostsForController:self];
	[self.busyIndicator startAnimating];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 2) {
		return (NSInteger)self.posts.count;
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
		NSDictionary *dict = [self.posts objectAtIndex:(NSUInteger)indexPath.row];
		cell.textLabel.text = [dict valueForKey:@"title"];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@", [dict valueForKey:@"id"], [dict valueForKey:@"owner"]];
		if ([[dict valueForKey:@"read"] boolValue]) {
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
		self.index = -1;
		NSString *boardname = self.navigationItem.title;
		if (self.digestsViewController == nil) {
			if (self.isPad) {
				self.digestsViewController = [[DigestsViewController alloc] initWithNibName:@"ListViewController_iPad" bundle:nil];
			} else {
				self.digestsViewController = [[DigestsViewController alloc] initWithNibName:@"ListViewController_iPhone" bundle:nil];
			}
			self.digestsViewController.core = self.core;
			self.digestsViewController.isPad = self.isPad;
			self.digestsViewController.board = boardname;
			self.digestsViewController.route = @"x";
			self.digestsViewController.navigationItem.title = boardname;
		}
		[self.navigationController pushViewController:self.digestsViewController animated:YES];
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
		self.core.contentOutput.postsViewController = self;
		NSDictionary *dict = [self.posts objectAtIndex:(NSUInteger)indexPath.row];
		NSInteger pid = [[dict valueForKey:@"id"] integerValue];
		self.index = pid;
		[self.core.contentOutput.busyIndicator startAnimating];
		self.core.contentOutput.navigationItem.rightBarButtonItem = nil;
		[self.core viewContentForController:self.core.contentOutput];
		NSInteger endid = self.offset;
		NSInteger startid = self.offset - (NSInteger)self.posts.count + 1;
		[dict setValue:[NSNumber numberWithBool:YES] forKey:@"read"];
		if (pid - startid < 10) {
			[self.core listPostsFrom:startid - 20 To:startid ForController:self];
		}
		if (endid - pid < 10) {
			[self.core listPostsFrom:endid To:endid + 20 ForController:self];
		}
		[self.tableView reloadData];
		if (self.index > 0) {
			NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.offset - self.index inSection:2];
			[self.tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
			[self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
		}
	} else if (indexPath.section == 1) {
		// new posts
		NSInteger endid = self.offset;
		self.index = endid;
		[self.core listPostsFrom:endid To:endid + 20 ForController:self];
		[self.busyIndicator startAnimating];
	} else if (indexPath.section == 3) {
		// old posts
		NSInteger startid = self.offset - (NSInteger)self.posts.count + 1;
		self.index = startid;
		[self.core listPostsFrom:startid - 20 To:startid ForController:self];
		[self.busyIndicator startAnimating];
	}
}

- (void)selectPostWithOffset:(NSInteger)offset
{
	NSInteger index = self.index + offset;
	NSInteger endid = self.offset;
	NSInteger startid = self.offset - (NSInteger)self.posts.count + 1;
	if (index > endid || index < startid) {
		return;
	}
	self.index = index;
	[self.core.contentOutput.busyIndicator startAnimating];
	self.core.contentOutput.navigationItem.rightBarButtonItem = nil;
	[self.core viewContentForController:self.core.contentOutput];
	NSDictionary *dict = [self.posts objectAtIndex:(NSUInteger)(self.offset - index)];
	[dict setValue:[NSNumber numberWithBool:YES] forKey:@"read"];
	if (index - startid < 10) {
		[self.core listPostsFrom:startid - 20 To:startid ForController:self];
	}
	if (endid - index < 10) {
		[self.core listPostsFrom:endid To:endid + 20 ForController:self];
	}
	[self.tableView reloadData];
	if (self.index > 0) {
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.offset - self.index inSection:2];
		[self.tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
		[self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
	}
}

- (void)updatePosts:(NSArray *)posts
{
	if (posts.count == 0) {
		return;
	}
	NSDictionary *lodict = [posts objectAtIndex:0];
	NSDictionary *hidict = [posts lastObject];
	NSInteger lo = [(NSNumber *)[lodict valueForKey:@"id"] integerValue];
	NSInteger hi = [(NSNumber *)[hidict valueForKey:@"id"] integerValue];
	if (lo > hi) {
		return;
	}
	NSInteger endid = self.offset;
	NSInteger startid = self.offset - (NSInteger)self.posts.count + 1;
	if (lo > endid + 1 || hi < startid - 1) {
		// discontinuous
		[self.posts removeAllObjects];
		endid = hi;
		startid = hi + 1;
	}
	NSEnumerator *e = [posts objectEnumerator];
	for (NSDictionary *dict in e) {
		NSInteger pid = [(NSNumber *)[dict valueForKey:@"id"] integerValue];
		if (pid > endid || pid < startid) {
			[self.posts addObject:dict];
		} else {
			NSDictionary *d = [self.posts objectAtIndex:(NSUInteger)(self.offset - pid)];
			if (![(NSString *)[d valueForKey:@"title"] isEqualToString:(NSString *)[dict valueForKey:@"title"]] || ![(NSNumber *)[d valueForKey:@"posttime"] isEqualToNumber:(NSNumber *)[dict valueForKey:@"posttime"]]) {
				[self.posts setArray:posts];
				break;
			}
		}
	}
	[self.posts sortUsingComparator:^(NSDictionary *left, NSDictionary *right) {
		NSUInteger leftid = [(NSNumber *)[left valueForKey:@"id"] unsignedIntegerValue];
		NSUInteger rightid = [(NSNumber *)[right valueForKey:@"id"] unsignedIntegerValue];
		if (leftid < rightid) {
			return (NSComparisonResult)NSOrderedDescending;
		}
		if (leftid > rightid) {
			return (NSComparisonResult)NSOrderedAscending;
		}
		return (NSComparisonResult)NSOrderedSame;
	}];
	self.offset = [(NSNumber *)[(NSDictionary *)[self.posts objectAtIndex:0] valueForKey:@"id"] unsignedIntegerValue];
	endid = self.offset;
	startid = self.offset - (NSInteger)self.posts.count + 1;
	if (self.index > endid) {
		self.index = endid;
	}
	if (self.index < startid) {
		self.index = startid;
	}
	[self.tableView reloadData];
	if (self.index > 0) {
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.offset - self.index inSection:2];
		[self.tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
		[self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
	}
	[self.busyIndicator stopAnimating];
}

- (void)post
{
	if (self.isPad) {
		UIViewController *controller = [self.core.contentOutput.navigationController presentedViewController];
		if (controller == self.core.postInput) {
			return;
		}
		[self.core.contentOutput.navigationController pushViewController:self.core.postInput animated:YES];
	} else {
		[self.navigationController pushViewController:self.core.postInput animated:YES];
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
