//
//  DigestsViewController.m
//  iWell
//
//  Created by Wu Weiyi on 10/9/12.
//
//

#import "DigestsViewController.h"

#import "ContentViewController.h"

@interface DigestsViewController ()

@property (strong, nonatomic) NSMutableArray *digests;
//	[
//		{
//			'mtitle': <string: menu title when listing children of this item>,
//			'title': <string: title of this item>,
//			'attach': <int: attachment position or attachment flag, with attachment <-> != 0>,
//			'mtime': <int: modification time>,
//			'type': <string: item type. can be file/dir/link/other>,
//			'id': <int: item index, start from 1>,
//			// these items only appear if type == link
//			'host': <string: link host>,
//			'post': <int: link port>
//		}
//	]

@end

@implementation DigestsViewController

@synthesize digestsViewControllers = _digestsViewControllers;
@synthesize digests = _digests;
@synthesize index = _index;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		 self.digests = [NSMutableArray array];
		 self.index = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.tableView.bounces = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.core listDigestsForController:self];
	[self.busyIndicator startAnimating];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return (NSInteger)self.digests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = @"Title";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	NSDictionary *dict = [self.digests objectAtIndex:(NSUInteger)indexPath.row];
	cell.textLabel.text = [dict valueForKey:@"title"];
	if ([(NSString *)[dict valueForKey:@"type"] isEqualToString:@"dir"]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.index = indexPath.row;
	NSDictionary *dict = [self.digests objectAtIndex:(NSUInteger)indexPath.row];
	if ([(NSString *)[dict valueForKey:@"type"] isEqualToString:@"dir"]) {
		// directory
		DigestsViewController *digestsViewController = [self.digestsViewControllers objectForKey:[dict valueForKey:@"id"]];
		if (digestsViewController == nil) {
			if (self.isPad) {
				digestsViewController = [[DigestsViewController alloc] initWithNibName:@"ListViewController_iPad" bundle:nil];
			} else {
				digestsViewController = [[DigestsViewController alloc] initWithNibName:@"ListViewController_iPhone" bundle:nil];
			}
			digestsViewController.core = self.core;
			digestsViewController.isPad = self.isPad;
			digestsViewController.board = self.board;
			digestsViewController.route = [NSString stringWithFormat:@"%@-%@", self.route, [dict valueForKey:@"id"]];
			digestsViewController.navigationItem.title = [dict valueForKey:@"mtitle"];
		}
		[self.navigationController pushViewController:digestsViewController animated:YES];
	} else {
		// regular
		if (!self.isPad) {
			[self.navigationController pushViewController:self.core.contentOutput animated:YES];
		} else {
			UIViewController *controller = [self.core.contentOutput.navigationController presentedViewController];
			if (controller != self.core.contentOutput) {
				[self.core.contentOutput.navigationController popViewControllerAnimated:YES];
			}
		}
		self.core.contentOutput.digestsViewController = self;
		[self.core.contentOutput.busyIndicator startAnimating];
		self.core.contentOutput.navigationItem.rightBarButtonItem = nil;
		[self.core viewDigestForController:self.core.contentOutput];
	}
}

- (void)updateDigests:(NSArray *)digests
{
	[self.digests setArray:digests];
	[self.tableView reloadData];
	if (self.index >= 0) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.index inSection:0];
		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
	}
	[self.busyIndicator stopAnimating];
}
@end
