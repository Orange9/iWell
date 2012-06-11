//
//  Core_Pad.m
//  iWell-Pad
//
//  Created by Wu Weiyi on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Core.h"

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "LoginViewController.h"
#import "PostViewController.h"

@interface Core ()
@property (strong, nonatomic) BBSCore *bbsCore;
@property (strong, nonatomic) PreferenceStorage *preferenceStorage;

@property (assign, nonatomic) NSInteger bIndex;
@property (assign, nonatomic) NSInteger index;

@property (strong, nonatomic) NSMutableArray *boards;
@property (strong, nonatomic) NSMutableDictionary *posts;
@property (strong, nonatomic) NSString *board;
@property (strong, nonatomic) NSString *title;

- (void)saveAddress:(NSString *)address;
- (void)saveUsername:(NSString *)username;
- (void)savePassword:(NSString *)password;
- (void)saveToken:(NSString *)token;
- (void)popLoginView;
- (void)setContentTitle;
- (void)setContent;
- (void)setQuote:(NSString *)content;
- (void)setQuoteTitle:(NSString *)title;
- (void)reloadPosts:(MasterViewController *)postsViewController;
- (void)reloadBoards;

@end

@implementation Core

@synthesize bbsCore = _bbsCore;
@synthesize preferenceStorage = _preferenceStorage;
@synthesize bIndex = _bIndex;
@synthesize index = _index;
@synthesize boards = _boards;
@synthesize posts = _posts;
@synthesize board = _board;
@synthesize title = _title;
@synthesize boardsOutput = _boardsOutput;
@synthesize postsOutputs = _postsOutputs;
@synthesize contentOutput = _contentOutput;
@synthesize postInput = _postInput;
@synthesize loginInput = _loginInput;
@synthesize isOAuth = _isOAuth;

#pragma mark - Public Methods

- (id)init
{
	self.preferenceStorage = [[PreferenceStorage alloc] init];
	
	self.bbsCore = [[BBSCore alloc] init];
	self.bbsCore.delegate = self;
	self.bbsCore.baseURL = [NSURL URLWithString:[self.preferenceStorage valueForKey:@"address"]];
	self.bbsCore.username = [self.preferenceStorage valueForKey:@"username"];
	self.bbsCore.password = [self.preferenceStorage valueForKey:@"password"];
	self.bbsCore.sessionToken = [self.preferenceStorage valueForKey:@"token"];
	self.boards = [NSMutableArray array];
	self.posts = [NSMutableDictionary dictionary];
	self.bIndex = -1;
	self.index = -1;
	
	self.boardsOutput = nil;
	self.postsOutputs = [NSMutableDictionary dictionary];
	self.contentOutput = nil;
	
	//[self.bbsCore connectWithStage:BBS_OAUTH_VERIFY];
	return self;
}

- (NSString *)address
{
	return [self.bbsCore.baseURL absoluteString];
}

- (NSString *)username
{
	return self.bbsCore.username;
}

- (NSString *)password
{
	return self.bbsCore.password;
}

- (NSDictionary *)boardInfoAtIndex:(NSUInteger)index
{
	NSDictionary *dict = [self.boards objectAtIndex:index];
	NSString *name = [dict objectForKey:@"name"];
	if (name == nil) {
		name = @"ERROR";
	}
	NSString *bm = [dict objectForKey:@"BM"];
	if (bm == nil) {
		bm = @"";
	}
	NSNumber *total = [dict objectForKey:@"total"];
	if (total == nil) {
		total = [NSNumber numberWithInteger:-1];
	}
	NSNumber *read = [dict objectForKey:@"read"];
	if (read == nil) {
		read = [NSNumber numberWithBool:NO];
	}
	return [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", bm, @"bm", total, @"total", read, @"read", nil];
}

- (NSDictionary *)postInfoAtIndex:(NSUInteger)index onBoard:(NSString *)board
{
	NSMutableArray *posts = [self.posts objectForKey:board];
	NSDictionary *dict = [posts objectAtIndex:index];
	NSString *title = [dict objectForKey:@"title"];
	if (title == nil) {
		title = @"ERROR";
	}
	NSString *owner = [dict objectForKey:@"owner"];
	if (owner == nil) {
		owner = @"";
	}
	NSNumber *postid = [dict objectForKey:@"id"];
	if (postid == nil) {
		postid = [NSNumber numberWithInteger:-1];
	}
	NSNumber *read = [dict objectForKey:@"read"];
	if (read == nil) {
		read = [NSNumber numberWithBool:NO];
	}
	return [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", owner, @"owner", postid, @"id", read, @"read", nil];
}

- (NSString *)boardNameAtIndex:(NSUInteger)index
{
	NSDictionary *dict = [self.boards objectAtIndex:index];
	NSString *name = [dict objectForKey:@"name"];
	if (name == nil) {
		return @"ERROR";
	}
	self.bIndex = index;
	return name;
}

- (NSUInteger)postIDAtIndex:(NSUInteger)index onBoard:(NSString *)board
{
	NSMutableArray *posts = [self.posts objectForKey:board];
	NSDictionary *dict = [posts objectAtIndex:index];
	NSNumber *postid = [dict objectForKey:@"id"];
	if (postid == nil) {
		return 0;
	}
	[dict setValue:[NSNumber numberWithBool:YES] forKey:@"read"];
	[posts replaceObjectAtIndex:index withObject:dict];
	self.index = index;
	
	MasterViewController *postsViewController = [self.postsOutputs valueForKey:board];
	[self performSelectorOnMainThread:@selector(reloadPosts:) withObject:postsViewController waitUntilDone:YES];
	return [postid unsignedIntegerValue];
}

- (NSUInteger)newestPostIDAtIndexOnBoard:(NSString *)board
{
	NSMutableArray *posts = [self.posts objectForKey:board];
	NSDictionary *dict = [posts objectAtIndex:0];
	NSNumber *postid = [dict objectForKey:@"id"];
	if (postid == nil) {
		return 0;
	}
	return [postid unsignedIntegerValue];
}

- (NSUInteger)oldestPostIDAtIndexOnBoard:(NSString *)board
{
	NSMutableArray *posts = [self.posts objectForKey:board];
	NSDictionary *dict = [posts lastObject];
	NSNumber *postid = [dict objectForKey:@"id"];
	if (postid == nil) {
		return 0;
	}
	return [postid unsignedIntegerValue];
}

- (NSUInteger)boardsCount
{
	return [self.boards count];
}

- (NSUInteger)postsCountOnBoard:(NSString *)board
{
	NSMutableArray *posts = [self.posts objectForKey:board];
	return [posts count];
}

- (void)OAuth:(NSString *)address
{
	[self saveAddress:address];
	[self.bbsCore OAuth];
}

- (void)connect:(NSString *)address withUsername:(NSString *)username Password:(NSString *)password
{
	[self saveAddress:address];
	[self saveUsername:username];
	[self savePassword:password];
	[self.bbsCore connectWithStage:BBS_OAUTH_ACCESS];
}

- (void)connectWithToken:(NSString *)token
{
	self.bbsCore.authorizationToken = token;
	[self.bbsCore connectWithStage:BBS_OAUTH_SESSION];
}

- (void)resume
{
	[self.bbsCore connectWithStage:BBS_OAUTH_VERIFY];
}

- (void)listBoards
{
	[self.bbsCore listBoardsInRange:NSMakeRange(1, 1000)];
}

- (void)listFavBoards
{
	[self.bbsCore listFavBoardsInRange:NSMakeRange(0, 0)];
}

- (void)listPostsOfBoard:(NSString *)board
{
	self.index = -1;
	MasterViewController *postViewController = [self.postsOutputs valueForKey:board];
	[self.bbsCore listPostsInRange:NSMakeRange(0, 20) onBoard:board];
}

- (void)listPostsNear:(NSUInteger)postid onBoard:(NSString *)board
{
	NSUInteger newest = [self newestPostIDAtIndexOnBoard:board];
	NSUInteger oldest = [self oldestPostIDAtIndexOnBoard:board];
	NSUInteger hi = postid;
	NSUInteger lo = postid;
	if (hi + 10 > newest) {
		hi = newest + 20;
	}
	if (lo - 10 < oldest) {
		lo = oldest - 20;
	}
	if (lo < hi) {
		[self.bbsCore listPostsInRange:NSMakeRange(lo, hi - lo + 1) onBoard:board];
	}
}

- (void)listNewerPostsOfBoard:(NSString *)board
{
	[self listPostsNear:[self newestPostIDAtIndexOnBoard:board] onBoard:board];
}

- (void)listOlderPostsOfBoard:(NSString *)board
{
	[self listPostsNear:[self oldestPostIDAtIndexOnBoard:board] onBoard:board];
}

- (void)viewContentOfPost:(NSUInteger)postid onBoard:(NSString *)board
{
	self.board = board;
	[self.bbsCore viewContentOfPost:postid onBoard:board];
}

- (void)viewContentOfNewerPost {
	if (self.index <= 0) return;
	NSUInteger postid = [self postIDAtIndex:(NSUInteger)self.index - 1 onBoard:self.board];
	[self viewContentOfPost:postid onBoard:self.board];
	MasterViewController *postsViewController = [self.postsOutputs objectForKey:self.board];
	NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.index inSection:1];
	[postsViewController.tableView selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)viewContentOfOlderPost {
	if (self.index >= (NSInteger)[self postsCountOnBoard:self.board] - 1) return;
	NSUInteger postid = [self postIDAtIndex:(NSUInteger)self.index + 1 onBoard:self.board];
	[self viewContentOfPost:postid onBoard:self.board];
	MasterViewController *postsViewController = [self.postsOutputs objectForKey:self.board];
	NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.index inSection:1];
	[postsViewController.tableView selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)viewQuoteOfPost:(NSUInteger)postid onBoard:(NSString *)board WithXID:(NSUInteger)xid
{
	[self.bbsCore viewQuoteOfPost:postid onBoard:board WithXID:xid];
}

- (void)post:(NSString *)content WithTitle:(NSString *)title onBoard:(NSString *)board WithID:(NSUInteger)postid WithXID:(NSUInteger)xid
{
	[self.bbsCore post:content WithTitle:title onBoard:board WithID:postid WithXID:xid];
}

#pragma mark - Private Methods

- (void)saveAddress:(NSString *)address
{
	NSURL *url = [NSURL URLWithString:address];
	if (![[self.bbsCore.baseURL absoluteString] isEqualToString:[url absoluteString]]) {
		self.bbsCore.baseURL = url;
	}
	[self.preferenceStorage setValue:address forKey:@"address"];
}

- (void)saveUsername:(NSString *)username
{
	if (![self.bbsCore.username isEqualToString:username]) {
		self.bbsCore.username = username;
	}
	[self.preferenceStorage setValue:username forKey:@"username"];
}

- (void)savePassword:(NSString *)password
{
	if (![self.bbsCore.password isEqualToString:password]) {
		self.bbsCore.password = password;
	}
	[self.preferenceStorage setValue:password forKey:@"password"];
}

- (void)saveToken:(NSString *)token
{
	if (![self.bbsCore.sessionToken isEqualToString:token]) {
		self.bbsCore.sessionToken = token;
	}
	[self.preferenceStorage setValue:token forKey:@"token"];
}

- (void)popLoginView
{
	[self.loginInput.navigationController popViewControllerAnimated:YES];
}

- (void)setContentTitle
{
	self.contentOutput.navigationItem.title = self.title;
}

- (void)setContent
{
	UIBarButtonItem *replyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self.contentOutput action:@selector(reply)];
	self.contentOutput.navigationItem.rightBarButtonItem = replyButton;
	[self.contentOutput.contentText setContentOffset:CGPointMake(0, 0) animated:NO];
	[self.contentOutput.contentText setNeedsDisplay];
}

- (void)setQuote:(NSString *)content
{
	NSMutableString *string = [NSMutableString stringWithString:@"\n\nSent from "];
	[string appendString:[UIDevice currentDevice].model];
	[string appendString:content];
	[self.postInput.contentInput setText:string];
	self.postInput.contentInput.selectedRange = NSMakeRange(0, 0);
}

- (void)setQuoteTitle:(NSString *)title
{
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.postInput action:@selector(post)];
	self.postInput.navigationItem.rightBarButtonItem = doneButton;
	[self.postInput.titleInput setText:title];
}

- (void)reloadPosts:(MasterViewController *)postsViewController
{
	[postsViewController.tableView reloadData];
	if (self.index >= 0) {
		NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.index inSection:1];
		[postsViewController.tableView selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void)reloadBoards
{
	[self.boardsOutput.tableView reloadData];
	if (self.bIndex >= 0) {
		NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.bIndex inSection:0];
		[self.boardsOutput.tableView selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionNone];
	}
}

#pragma mark - Delegate Methods

- (void)online:(NSString *)token
{
	if (!self.isOAuth) {
		[self performSelectorOnMainThread:@selector(popLoginView) withObject:nil waitUntilDone:YES];
	} else {
		[self.boardsOutput viewWillAppear:YES];
	}
	[self.preferenceStorage setValue:token forKey:@"token"];
}

- (void)printContent:(NSString *)content
{
	self.title = content;
	[self performSelectorOnMainThread:@selector(setContentTitle) withObject:nil waitUntilDone:YES];
}

- (void)showContent:(NSDictionary *)content onBoard:(NSString *)board
{
	self.contentOutput.board = board;
	NSNumber *pid = [content objectForKey:@"id"];
	if (pid == nil) {
		self.contentOutput.postid = 0;
	} else {
		self.contentOutput.postid = [pid unsignedIntegerValue];
		[self listPostsNear:[pid unsignedIntegerValue] onBoard:board];
	}
	pid = [content objectForKey:@"xid"];
	if (pid == nil) {
		self.contentOutput.xid = 0;
	} else {
		self.contentOutput.xid = [pid unsignedIntegerValue];
	}
	NSString *string = [content objectForKey:@"content"];
	if (string == nil) {
		string = @"";
	}
	self.contentOutput.contentText.string = string;
	string = [content objectForKey:@"title"];
	if (string == nil) {
		string = @"";
	}
	self.title = string;
	[self performSelectorOnMainThread:@selector(setContent) withObject:nil waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(setContentTitle) withObject:nil waitUntilDone:YES];
}

- (void)showQuote:(NSDictionary *)content onBoard:(NSString *)board withID:(NSUInteger)postid WithXID:(NSUInteger)xid
{
	NSString *string = [content objectForKey:@"content"];
	if (string == nil) {
		string = @"";
	}
	[self performSelectorOnMainThread:@selector(setQuote:) withObject:string waitUntilDone:YES];
	string = [content objectForKey:@"title"];
	if (string == nil) {
		string = @"";
	}
	[self performSelectorOnMainThread:@selector(setQuoteTitle:) withObject:string waitUntilDone:YES];
}

- (void)showPosts:(NSArray *)posts onBoard:(NSString *)board
{
	if ([posts count] == 0) return;
	MasterViewController *postsViewController = [self.postsOutputs valueForKey:board];
	NSUInteger start = 0, end = 0, importstart = 0, importend = 0;
	NSMutableArray *list = [self.posts valueForKey:board];
	if (list == nil) {
		list = [NSMutableArray array];
		[self.posts setValue:list forKey:board];
	}
	NSDictionary *dict = [posts objectAtIndex:0];
	NSNumber *postid = [dict objectForKey:@"id"];
	if (postid == nil) {
		return;
	}
	importstart = [postid unsignedIntegerValue];
	
	dict = [posts lastObject];
	postid = [dict objectForKey:@"id"];
	if (postid == nil) {
		return;
	}
	importend = [postid unsignedIntegerValue];
	
	if ([list count] != 0) {
		dict = [list lastObject];
		postid = [dict objectForKey:@"id"];
		if (postid == nil) {
			return;
		}
		start = [postid unsignedIntegerValue];
		
		dict = [list objectAtIndex:0];
		postid = [dict objectForKey:@"id"];
		if (postid == nil) {
			return;
		}
		end = [postid unsignedIntegerValue];
	} else {
		start = importend + 1;
		end = importend;
	}
	if (importend > end) {
		NSEnumerator *e = [posts objectEnumerator];
		for (NSDictionary *d in e) {
			NSNumber *pid = [d objectForKey:@"id"];
			if (pid == nil) {
				return;
			}
			if ([pid unsignedIntegerValue] == end + 1) {
				[list insertObject:d atIndex:0];
				end++;
				self.index = self.index + 1;
			}
		}
	} else {
		NSEnumerator *e = [posts reverseObjectEnumerator];
		for (NSDictionary *d in e) {
			NSNumber *pid = [d objectForKey:@"id"];
			if (pid == nil) {
				return;
			}
			if ([pid unsignedIntegerValue] == start - 1) {
				[list addObject:d];
				start--;
			}
		}
	}
	[self performSelectorOnMainThread:@selector(reloadPosts:) withObject:postsViewController waitUntilDone:YES];
}

- (void)showBoards:(NSArray *)boards
{
	[self.boards setArray:boards];
	[self performSelectorOnMainThread:@selector(reloadBoards) withObject:nil waitUntilDone:YES];
}

@end

@implementation View

@synthesize string;
@synthesize converter;

- (void)awakeFromNib
{
	self.contentMode = UIViewContentModeRedraw;
	converter = [StringConverter converter];
	NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(blink) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode]; 
	[super awakeFromNib];
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	dirtyRect.origin = self.contentOffset;
	self.contentSize = [converter draw:self.string InContext:context InRect:&dirtyRect];
	[super drawRect:dirtyRect];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self setNeedsDisplay];
}

- (void)blink
{
	self.converter.blink = !self.converter.blink;
	[self setNeedsDisplay];
}

@end
