//
//  BBSCore.m
//  iWell
//
//  Created by Wu Weiyi on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBSCore.h"

static NSString *reqPath[] = { @"/board/list", @"/favboard/list", @"/board/post_list", @"/post/view", @"/post/quote", @"/post/new" };
static NSString *reqString = @"iWell_Req";

@interface BBSCore ()
@property (strong, nonatomic) SBJsonParser *parser;

@property (strong, nonatomic) NetCore *netCore;

@property (assign, nonatomic) enum bbs_stage_t stage;

@property (strong, nonatomic) NSMutableArray *reqQueue;
@property (strong, nonatomic) NSMutableDictionary *reqMap;

@property (strong, nonatomic) NSString *authorizationToken;
@property (strong, nonatomic) NSString *sessionToken;

@property (strong, nonatomic) NSCondition *condition;

- (void)OAuthWithUserInfo;
- (void)OAuthWithToken;

- (void)run;

@end

@implementation BBSCore

@synthesize baseURL = _baseURL;
@synthesize username = _username;
@synthesize password = _password;

@synthesize parser = _parser;
@synthesize netCore = _netCore;
@synthesize delegate = _delegate;
@synthesize stage = _stage;
@synthesize reqQueue = _reqQueue;
@synthesize reqMap = _reqMap;
@synthesize authorizationToken = _authorizationToken;
@synthesize sessionToken = _sessionToken;
@synthesize condition = _condition;

#pragma mark - Public Methods

- (BBSCore *)init
{
	self.stage = BBS_IDLE;
	self.netCore = [[NetCore alloc] initWithDelegate:self];
	self.reqQueue = [NSMutableArray array];
	self.reqMap = [NSMutableDictionary dictionary];
	self.authorizationToken = [NSMutableString string];
	self.sessionToken = [NSMutableString string];
	self.parser = [[SBJsonParser alloc] init];
	self.condition = [[NSCondition alloc] init];
	return self;
}

- (void)connect
{
	if (self.stage == BBS_IDLE) {
		self.stage = BBS_OAUTH_ACCESS;
		// [receiver showContent:@"\e[41mabcdefghijklmnopqrstuvwxyz\nABCDEGHIJK"];
		//	[receiver showContent:@"\e[30mabcdefgh\e[31mabcdefgh\e[32mabcdefgh\e[33mabcdefgh\e[34mabcdefgh\e[35mabcdefgh\e[36mabcdefgh\e[37mabcdefgh\e[30;1mabcdefgh\e[31;1mabcdefgh\e[32;1mabcdefgh\e[33;1mabcdefgh\e[34;1mabcdefgh\e[35;1mabcdefgh\e[36;1mabcdefgh\e[37;1mabcdefgh\e[mXXXXXX\e[40mabcdefgh\e[41mabcdefgh\e[42mabcdefgh\e[43mabcdefgh\e[44mabcdefgh\e[45mabcdefgh\e[46mabcdefgh\e[47mabcdefgh\e[40;1mabcdefgh\e[41;1mabcdefgh\e[42;1mabcdefgh\e[43;1mabcdefgh\e[44;1mabcdefgh\e[45;1mabcdefgh\e[46;1mabcdefgh\e[47;1mabcdefgh\e[mXXXXXX\e[31;42mabcdefgh\e[30;42mabcdefgh"];
		// [receiver showContent:@"MMMMMHHHHHMMMMMHHHHHMMMMMHHHHHMMMMMHHHHHMMMMMHHHHHMMMMMHHHHHMMMMMHHHHHMMMMMHHHHH\n国国国国国同同同同同国国国国国同同同同同国国国国国同同同同同国国国国国同同同同同"];
		// [receiver printContent:@"abcdefghijABCDEFGHIJklmnopqrstKLMNOPQRST1234567890"];
		// [receiver showContent:@"\e[31m红RED\e[32mGREEN绿\e[m黑\n\e[41m红底\e[42m绿底\e[31m红字\e[1m亮\e[m"];
		[NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
	}
}

- (void)disconnect
{
	self.stage = BBS_IDLE;
}

- (void)listBoardsInRange:(NSRange)range
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_BOARDS_LIST] forKey:reqString];
	[data setValue:self.sessionToken forKey:@"session"];
	if (range.location > 0) {
		[data setValue:[NSNumber numberWithUnsignedInteger:range.location] forKey:@"start"]; //optional
	}
	//	[data setValue:@"100" forKey:@"end"]; //optional
	if (range.length > 0) {
		[data setValue:[NSNumber numberWithUnsignedInteger:range.length] forKey:@"count"]; //optional
	}
	[self.condition lock];
	[self.reqQueue addObject:data];
	[self.condition signal];
	[self.condition unlock];
}

- (void)listFavBoardsInRange:(NSRange)range
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_FAVBOARDS_LIST] forKey:reqString];
	[data setValue:self.sessionToken forKey:@"session"];
	if (range.location > 0) {
		[data setValue:[NSNumber numberWithUnsignedInteger:range.location] forKey:@"start"]; //optional
	}
	//	[data setValue:@"100" forKey:@"end"]; //optional
	if (range.length > 0) {
		[data setValue:[NSNumber numberWithUnsignedInteger:range.length] forKey:@"count"]; //optional
	}
	[self.condition lock];
	[self.reqQueue addObject:data];
	[self.condition signal];
	[self.condition unlock];
}

- (void)listPostsInRange:(NSRange)range onBoard:(NSString *)board
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_POSTS_LIST] forKey:reqString];
	[data setValue:self.sessionToken forKey:@"session"];
	[data setValue:board forKey:@"name"];
	[data setValue:@"normal" forKey:@"mode"]; //optional, normal/digest/mark/deleted/junk
	if (range.location > 0) {
		[data setValue:[NSNumber numberWithUnsignedInteger:range.location] forKey:@"start"]; //optional
	}
	//	[data setValue:@"100" forKey:@"end"]; //optional
	if (range.length > 0) {
		[data setValue:[NSNumber numberWithUnsignedInteger:range.length] forKey:@"count"]; //optional
	}
	[self.condition lock];
	[self.reqQueue addObject:data];
	[self.condition signal];
	[self.condition unlock];
}

- (void)viewContentOfPost:(NSUInteger)postid onBoard:(NSString *)board
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_CONTENT_VIEW] forKey:reqString];
	[data setValue:self.sessionToken forKey:@"session"];
	[data setValue:[NSNumber numberWithUnsignedInteger:postid] forKey:@"id"];
	[data setValue:board forKey:@"board"];
	[self.condition lock];
	[self.reqQueue addObject:data];
	[self.condition signal];
	[self.condition unlock];
}

- (void)viewQuoteOfPost:(NSUInteger)postid onBoard:(NSString *)board WithXID:(NSUInteger)xid
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_QUOTE_VIEW] forKey:reqString];
	[data setValue:self.sessionToken forKey:@"session"];
	[data setValue:[NSNumber numberWithUnsignedInteger:postid] forKey:@"id"];
	[data setValue:[NSNumber numberWithUnsignedInteger:xid] forKey:@"xid"];
	[data setValue:board forKey:@"board"];
	[self.condition lock];
	[self.reqQueue addObject:data];
	[self.condition signal];
	[self.condition unlock];
}

- (void)post:(NSString *)content WithTitle:(NSString *)title onBoard:(NSString *)board WithID:(NSUInteger)postid WithXID:(NSUInteger)xid
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_POST] forKey:reqString];
	[data setValue:self.sessionToken forKey:@"session"];
	if (postid > 0) {
		[data setValue:[NSNumber numberWithUnsignedInteger:postid] forKey:@"re_id"];
	}
	if (xid > 0) {
		[data setValue:[NSNumber numberWithUnsignedInteger:xid] forKey:@"re_xid"];
	}
	[data setValue:title forKey:@"title"];
	[data setValue:content forKey:@"content"];
	[data setValue:board forKey:@"board"];
	[self.condition lock];
	[self.reqQueue addObject:data];
	[self.condition signal];
	[self.condition unlock];
}

#pragma mark - Private Methods

- (void)OAuthWithUserInfo
{
	if (self.stage != BBS_OAUTH_ACCESS) return;
	self.stage = BBS_OAUTH_ACCESS_RECV;
	NSString *path = @"/auth/authpage";
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:@"displaycode" forKey:@"redirect_uri"];
	[data setValue:@"1" forKey:@"client_id"];
	[data setValue:self.username forKey:@"name"];
	[data setValue:self.password forKey:@"pass"];
	[self.netCore post:[NSURL URLWithString:path relativeToURL:self.baseURL] Data:data];
}

- (void)OAuthWithToken
{
	if (self.stage != BBS_OAUTH_SESSION) return;
	self.stage = BBS_OAUTH_SESSION_RECV;
	NSString *path = @"/auth/token";
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:self.authorizationToken forKey:@"code"];
	[data setValue:@"displaycode" forKey:@"redirect_uri"];
	[data setValue:@"authorization_code" forKey:@"grant_type"];
	[data setValue:@"1" forKey:@"client_id"];
	[data setValue:@"1" forKey:@"client_secret"];
	[self.netCore get:[NSURL URLWithString:path relativeToURL:self.baseURL] Data:data];
}

- (void)run
{
	@autoreleasepool {
		while (self.stage != BBS_IDLE) {
			switch (self.stage) {
				case BBS_OAUTH_ACCESS:
				{
					[self.delegate printContent:@"CONNECTING ..."];
					[self OAuthWithUserInfo];
					break;
				}
				case BBS_OAUTH_SESSION:
				{
					[self.delegate printContent:@"LOGGING IN ..."];
					[self OAuthWithToken];
					break;
				}
				case BBS_ONLINE:
				{
					[self.condition lock];
					if ([self.reqQueue count] == 0) {
						[self.condition wait];
					}
					[self.condition unlock];
					if ([self.reqQueue count] > 0) {
						NSMutableDictionary *packedData = [self.reqQueue objectAtIndex:0];
						NSNumber *reqNumber = [packedData valueForKey:reqString];
						[packedData removeObjectForKey:reqString];
						enum bbs_req_t req = [reqNumber unsignedIntegerValue];
						NSArray *array;
						if (req == BBS_BOARDS_LIST || req == BBS_FAVBOARDS_LIST) {
							array = [NSArray arrayWithObject:reqNumber];
						} else if (req == BBS_POSTS_LIST) {
							array = [NSArray arrayWithObjects:reqNumber, [packedData valueForKey:@"name"], nil];
						} else if (req == BBS_CONTENT_VIEW) {
							array = [NSArray arrayWithObjects:reqNumber, [packedData valueForKey:@"board"], [packedData valueForKey:@"id"], nil];
						} else if (req == BBS_QUOTE_VIEW) {
							array = [NSArray arrayWithObjects:reqNumber, [packedData valueForKey:@"board"], [packedData valueForKey:@"id"], [packedData valueForKey:@"xid"], nil];
						} else if (req == BBS_POST) {
							array = [NSArray arrayWithObjects:reqNumber, [packedData valueForKey:@"board"], [packedData valueForKey:@"id"], [packedData valueForKey:@"xid"], nil];
						} else break;
						NSNumber *index;
						if (req != BBS_POST) {
							index = [self.netCore get:[NSURL URLWithString:reqPath[req] relativeToURL:self.baseURL] Data:packedData];
						} else {
							index = [self.netCore post:[NSURL URLWithString:reqPath[req] relativeToURL:self.baseURL] Data:packedData];
						}
						[self.condition lock];
						[self.reqMap setObject:array forKey:index];
						[self.reqQueue removeObjectAtIndex:0];
						[self.condition unlock];
					}
					break;
				}
				default:
					break;
			}
		}
		[self.reqQueue removeAllObjects];
		[self.reqMap removeAllObjects];
	}
}

#pragma mark - Delegate Methods

- (void)recv:(NSData *)data Error:(NSError *)error Index:(NSNumber *)index
{
	if (data == nil) {
		// something bad happens
		NSString *string = [NSString stringWithFormat:@"%d: %@", error.code, error.localizedDescription];
		[self.delegate printContent:string];
		if (error.code != NSURLErrorTimedOut) {
			self.stage = BBS_IDLE;
		}
	} else {
		switch (self.stage) {
			case BBS_OAUTH_ACCESS_RECV:
			{
				// Your authorization code is: <b>XXXXXXXX</b>
				NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				NSRange range1 = [dataString rangeOfString:@"code is: <b>"];
				range1.location += 12;
				if (range1.length == 0) {
					self.stage = BBS_IDLE;
					[self.delegate printContent:@"OAUTH ERROR"];
					goto wakeup;
				}
				NSRange range2 = [dataString rangeOfString:@"<" options:0 range:range1];
				range1.length = range2.location - range1.location;
				self.authorizationToken = [dataString substringWithRange:range1];
				self.stage = BBS_OAUTH_SESSION;
				return;
			}
			case BBS_OAUTH_SESSION_RECV:
			{
				// {"access_token": <string: Token>, "token_type": <string: Token type>}
				id dict = [self.parser objectWithData:data];
				if ([dict isKindOfClass:[NSDictionary class]]) {
					NSString *value = [(NSDictionary *)dict objectForKey:@"token_type"];
					if (value != nil && [value isEqualToString:@"session"]) {
						value = [(NSDictionary *)dict objectForKey:@"access_token"];
						if (value != nil) {
							self.sessionToken = value;
							self.stage = BBS_ONLINE;
							[self.delegate printContent:@"READY"];
							[self.delegate online];
							return;
						}
					}
				}
				self.stage = BBS_IDLE;
				[self.delegate printContent:@"OAUTH FAILED"];
				goto wakeup;
			}
			case BBS_ONLINE:
			{
				NSArray *reqInfo = [self.reqMap objectForKey:index];
				NSNumber *reqNumber = [reqInfo objectAtIndex:0];
				enum bbs_req_t req = [reqNumber unsignedIntegerValue];
				[self.condition lock];
				[self.reqMap removeObjectForKey:index];
				[self.condition unlock];
				switch (req) {
					case BBS_BOARDS_LIST:
					{
						// [{"name": <string: Board name>, "read": <Boolean: Board read?>, "BM": <string: BMs>, "id": <int: Board id>, "total": <int: Total post count>, "currentusers": <int: Current users count>},{...}...]
						id array = [self.parser objectWithData:data];
						if ([array isKindOfClass:[NSArray class]]) {
							[self.delegate showBoards:array];
							return;
						}
						[self.delegate printContent:@"DATA CORRUPTED"];
						return;
					}
					case BBS_FAVBOARDS_LIST:
					{
						// [{"binfo": {"name": <string: Board name>, "read": <Boolean: Board read?>, "BM": <string: BMs>, "id": <int: Board id>, "total": <int: Total post count>, "currentusers": <int: Current users count>}, "father": <string: father>, "index": <int: index>, "type": <string: type> ,{...}...]
						id array = [self.parser objectWithData:data];
						if ([array isKindOfClass:[NSArray class]]) {
							NSMutableArray *newArray = [NSMutableArray array];
							for (NSDictionary *dict in array) {
								NSDictionary *value = [dict objectForKey:@"binfo"];
								[newArray addObject:value];
							}
							[self.delegate showBoards:newArray];
							return;
						}
						[self.delegate printContent:@"DATA CORRUPTED"];
						return;
					}
					case BBS_POSTS_LIST:
					{
						// [{"posttime": <time: post time>, "attachflag": <int: unknown>, "read": <Boolean: Post read>, "title": <string: Post title>, "attachment": <int: Attachment count>, "owner": <string: Poster userid>, "id": <int: Post id>, "xid": <int: unique post ID>}, {...}...]
						NSString *board = [reqInfo objectAtIndex:1];
						if ([data length] == 0) {
							[self.delegate showPosts:[NSArray array] onBoard:board];
							return;
						}
						id array = [self.parser objectWithData:data];
						if ([array isKindOfClass:[NSArray class]]) {
							[self.delegate showPosts:array onBoard:board];
							return;
						}
						[self.delegate printContent:@"DATA CORRUPTED"];
						return;
					}
					case BBS_CONTENT_VIEW:
					{
						// {"picattach": [{"name": <string: Attachment filename>, "offset:": <int: Attachment offset in post>}, {...}...], "title": <string: Post title>, "content": <string: Post content>, "otherattach": [{...}...], "owner": <string: Poster>, "id": <int: Post ID>, "xid": <int: unique post ID>}
						NSString *board = [reqInfo objectAtIndex:1];
						id dict = [self.parser objectWithData:data];
						if ([dict isKindOfClass:[NSDictionary class]]) {
							[self.delegate showContent:dict onBoard:board];
							return;
						}
						[self.delegate printContent:@"DATA CORRUPTED"];
						return;
					}
					case BBS_QUOTE_VIEW:
					{
						// {"content": <string: Post content encoded in Base64>, "name": <string: Attachment name>}
						NSString *board = [reqInfo objectAtIndex:1];
						NSNumber *postid = [reqInfo objectAtIndex:2];
						NSNumber *xid = [reqInfo objectAtIndex:3];
						id dict = [self.parser objectWithData:data];
						if ([dict isKindOfClass:[NSDictionary class]]) {
							[self.delegate showQuote:dict onBoard:board withID:[postid unsignedIntegerValue] WithXID:[xid unsignedIntegerValue]];
							return;
						}
						[self.delegate printContent:@"DATA CORRUPTED"];
						return;
					}
					case BBS_POST:
					{
						// nothing
						return;
					}
				}
			}
				
			default:
				return;
		}
	}
wakeup:
	[self.condition lock];
	[self.condition signal];
	[self.condition unlock];
}

@end
