//
//  BBSCore.m
//  iWell
//
//  Created by Wu Weiyi on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBSCore.h"

static NSString *reqPath[] = {
	@"/board/list",
	@"/favboard/list",
	@"/board/post_list",
	@"/digest/list",
	@"/post/view",
	@"/digest/view",
	@"/post/quote",
	@"/post/new"
};
static NSString *reqString = @"iWell_Req";
static NSString *controllerString = @"iWell_Controller";

@interface BBSCore ()
@property (strong, nonatomic) SBJsonParser *parser;

@property (strong, nonatomic) NetCore *netCore;

@property (assign, nonatomic) enum bbs_stage_t stage;

@property (strong, nonatomic) NSMutableArray *reqQueue;
@property (strong, nonatomic) NSMutableDictionary *reqMap;

@property (strong, nonatomic) NSCondition *condition;

- (void)OAuthWithToken;
- (void)OAuthVerify;

- (void)run;

@end

@implementation BBSCore

@synthesize baseURL = _baseURL;

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

- (void)OAuth
{
	NSString *path = @"/auth/auth";
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:@"iwell9://" forKey:@"redirect_uri"];
	[data setValue:@"code" forKey:@"response_type"];
	[data setValue:@"1" forKey:@"client_id"];
	[self.netCore open:[NSURL URLWithString:path relativeToURL:self.baseURL] Data:data];
}

- (void)connectWithStage:(enum bbs_stage_t)stage
{
	if (stage == BBS_OAUTH_SESSION || stage == BBS_OAUTH_VERIFY) {
		self.stage = stage;
		[NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
	}
}

- (void)disconnect
{
	self.stage = BBS_IDLE;
}

- (void)listBoardsInRange:(NSRange)range ForController:(id)controller
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_BOARDS_LIST] forKey:reqString];
	[data setValue:controller forKey:controllerString];
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

- (void)listFavBoardsInRange:(NSRange)range ForController:(id)controller
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_FAVBOARDS_LIST] forKey:reqString];
	[data setValue:controller forKey:controllerString];
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

- (void)listPostsInRange:(NSRange)range OnBoard:(NSString *)board ForController:(id)controller
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_POSTS_LIST] forKey:reqString];
	[data setValue:controller forKey:controllerString];
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

- (void)listDigestInRange:(NSRange)range OnBoard:(NSString *)board WithRoute:(NSString *)route ForController:(id)controller
{
	
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_DIGEST_LIST] forKey:reqString];
	[data setValue:controller forKey:controllerString];
	[data setValue:self.sessionToken forKey:@"session"];
	if (board != nil) {
		[data setValue:board forKey:@"board"];
	}
	[data setValue:route forKey:@"route"];
	if (range.location > 0) {
		[data setValue:[NSNumber numberWithUnsignedInteger:range.location] forKey:@"start"]; //optional
	}
	if (range.length > 0) {
		[data setValue:[NSNumber numberWithUnsignedInteger:range.location + range.length] forKey:@"end"]; //optional
	}
	[self.condition lock];
	[self.reqQueue addObject:data];
	[self.condition signal];
	[self.condition unlock];
}

- (void)viewContentOfPost:(NSUInteger)postid OnBoard:(NSString *)board ForController:(id)controller
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_CONTENT_VIEW] forKey:reqString];
	[data setValue:controller forKey:controllerString];
	[data setValue:self.sessionToken forKey:@"session"];
	[data setValue:[NSNumber numberWithUnsignedInteger:postid] forKey:@"id"];
	[data setValue:board forKey:@"board"];
	[self.condition lock];
	[self.reqQueue addObject:data];
	[self.condition signal];
	[self.condition unlock];
}

- (void)viewDigestWithRoute:(NSString *)route OnBoard:(NSString *)board ForController:(id)controller
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_DIGEST_VIEW] forKey:reqString];
	[data setValue:controller forKey:controllerString];
	[data setValue:self.sessionToken forKey:@"session"];
	[data setValue:route forKey:@"route"];
	[data setValue:board forKey:@"board"];
	[self.condition lock];
	[self.reqQueue addObject:data];
	[self.condition signal];
	[self.condition unlock];
}

- (void)viewQuoteOfPost:(NSUInteger)postid OnBoard:(NSString *)board WithXID:(NSUInteger)xid ForController:(id)controller
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_QUOTE_VIEW] forKey:reqString];
	[data setValue:controller forKey:controllerString];
	[data setValue:self.sessionToken forKey:@"session"];
	[data setValue:[NSNumber numberWithUnsignedInteger:postid] forKey:@"id"];
	[data setValue:[NSNumber numberWithUnsignedInteger:xid] forKey:@"xid"];
	[data setValue:board forKey:@"board"];
	[self.condition lock];
	[self.reqQueue addObject:data];
	[self.condition signal];
	[self.condition unlock];
}

- (void)post:(NSString *)content WithTitle:(NSString *)title OnBoard:(NSString *)board WithID:(NSUInteger)postid WithXID:(NSUInteger)xid ForController:(id)controller
{
	if (self.stage != BBS_ONLINE) return;
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:[NSNumber numberWithUnsignedInteger:BBS_POST] forKey:reqString];
	[data setValue:controller forKey:controllerString];
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

- (void)OAuthVerify
{
	if (self.stage != BBS_OAUTH_VERIFY) return;
	self.stage = BBS_OAUTH_VERIFY_RECV;
	NSString *path = @"/session/verify";
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setValue:self.sessionToken forKey:@"session"];
	[self.netCore get:[NSURL URLWithString:path relativeToURL:self.baseURL] Data:data];
}

- (void)run
{
	@autoreleasepool {
		while (self.stage != BBS_IDLE) {
			switch (self.stage) {
				case BBS_OAUTH_SESSION:
				{
					//	[self.delegate printContent:@"LOGGING IN ..."];
					[self OAuthWithToken];
					break;
				}
				case BBS_OAUTH_VERIFY:
				{
					//	[self.delegate printContent:@"RESUMING ..."];
					[self OAuthVerify];
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
						id controller = [packedData valueForKey:controllerString];
						[packedData removeObjectForKey:controllerString];
						enum bbs_req_t req = [reqNumber unsignedIntegerValue];
						NSArray *array;
						if (req == BBS_BOARDS_LIST || req == BBS_FAVBOARDS_LIST) {
							array = [NSArray arrayWithObjects:reqNumber, controller, nil];
						} else if (req == BBS_POSTS_LIST) {
							array = [NSArray arrayWithObjects:reqNumber, controller, nil];
						} else if (req == BBS_DIGEST_LIST) {
							array = [NSArray arrayWithObjects:reqNumber, controller, nil];
						} else if (req == BBS_CONTENT_VIEW) {
							array = [NSArray arrayWithObjects:reqNumber, controller, [packedData valueForKey:@"board"], [packedData valueForKey:@"id"], nil];
						} else if (req == BBS_DIGEST_VIEW) {
							array = [NSArray arrayWithObjects:reqNumber, controller, [packedData valueForKey:@"route"], [packedData valueForKey:@"board"], nil];
						} else if (req == BBS_QUOTE_VIEW) {
							array = [NSArray arrayWithObjects:reqNumber, controller, [packedData valueForKey:@"board"], [packedData valueForKey:@"id"], [packedData valueForKey:@"xid"], nil];
						} else if (req == BBS_POST) {
							array = [NSArray arrayWithObjects:reqNumber, controller, [packedData valueForKey:@"board"], [packedData valueForKey:@"id"], [packedData valueForKey:@"xid"], nil];
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
			case BBS_OAUTH_SESSION_RECV:
			{
				// {"access_token": <string: Token>, "token_type": <string: Token type>}
				id dict = [self.parser objectWithData:data];
				if ([dict isKindOfClass:[NSDictionary class]]) {
					NSString *value = [(NSDictionary *)dict valueForKey:@"token_type"];
					if (value != nil && [value isEqualToString:@"session"]) {
						value = [(NSDictionary *)dict valueForKey:@"access_token"];
						if (value != nil) {
							self.sessionToken = value;
							self.stage = BBS_ONLINE;
							//	[self.delegate printContent:@"READY"];
							[self.delegate online:value];
							return;
						}
					}
				}
				self.stage = BBS_IDLE;
				[self.delegate printContent:@"OAUTH FAILED"];
				goto wakeup;
			}
			case BBS_OAUTH_VERIFY_RECV:
			{
				// {"status": <string: Status>}
				id dict = [self.parser objectWithData:data];
				if ([dict isKindOfClass:[NSDictionary class]]) {
					NSString *value = [(NSDictionary *)dict valueForKey:@"status"];
					if (value != nil && [value isEqualToString:@"ok"]) {
						self.stage = BBS_ONLINE;
						//	[self.delegate printContent:@"READY"];
						[self.delegate online:self.sessionToken];
						return;
					}
				}
				self.stage = BBS_IDLE;
				[self.delegate printContent:@"RESUMING FAILED, NEED RECONNECT"];
				goto wakeup;
			}
			case BBS_ONLINE:
			{
				NSArray *reqInfo = [self.reqMap objectForKey:index];
				NSNumber *reqNumber = [reqInfo objectAtIndex:0];
				id controller = [reqInfo objectAtIndex:1];
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
							[self.delegate showBoards:array ForController:controller];
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
								NSDictionary *value = [dict valueForKey:@"binfo"];
								[newArray addObject:value];
							}
							[self.delegate showBoards:newArray ForController:controller];
							return;
						}
						[self.delegate printContent:@"DATA CORRUPTED"];
						return;
					}
					case BBS_POSTS_LIST:
					{
						// [{"posttime": <time: post time>, "attachflag": <int: unknown>, "read": <Boolean: Post read>, "title": <string: Post title>, "attachment": <int: Attachment count>, "owner": <string: Poster userid>, "id": <int: Post id>, "xid": <int: unique post ID>}, {...}...]
						if ([data length] == 0) {
							[self.delegate showPosts:[NSArray array] ForController:controller];
							return;
						}
						id array = [self.parser objectWithData:data];
						if ([array isKindOfClass:[NSArray class]]) {
							[self.delegate showPosts:array ForController:controller];
							return;
						}
						[self.delegate printContent:@"DATA CORRUPTED"];
						return;
					}
					case BBS_DIGEST_LIST:
					{
						// {'parent': <DigestItem: information of the directory>, 'count': <int: number of items returned>, 'items': [{'mtitle': <string: menu title when listing children of this item>, 'title': <string: title of this item>, 'attach': <int: attachment position or attachment flag, with attachment <-> != 0>, 'mtime': <int: modification time>, 'type': <string: item type. can be file/dir/link/other>, 'id': <int: item index, start from 1>, (these items only appear if type == link) 'host': <string: link host>, 'post': <int: link port>}, {...}...]}
						if ([data length] == 0) {
							[self.delegate showDigests:[NSArray array] ForController:controller];
							return;
						}
						
						id dict = [self.parser objectWithData:data];
						if ([dict isKindOfClass:[NSDictionary class]]) {
							id array = [dict valueForKey:@"items"];
							if ([array isKindOfClass:[NSArray class]]) {
								[self.delegate showDigests:array ForController:controller];
								return;
							}
						}
						[self.delegate printContent:@"DATA CORRUPTED"];
						return;
					}
					case BBS_CONTENT_VIEW:
					{
						// {"picattach": [{"name": <string: Attachment filename>, "offset:": <int: Attachment offset in post>}, {...}...], "title": <string: Post title>, "content": <string: Post content>, "otherattach": [{...}...], "owner": <string: Poster>, "id": <int: Post ID>, "xid": <int: unique post ID>}
						NSString *board = [reqInfo objectAtIndex:2];
						id dict = [self.parser objectWithData:data];
						if ([dict isKindOfClass:[NSDictionary class]]) {
							[self.delegate showContent:dict OnBoard:board ForController:controller];
							return;
						}
						[self.delegate printContent:@"DATA CORRUPTED"];
						return;
					}
					case BBS_DIGEST_VIEW:
					{
						// {'item': <DigestItem: information of the post item>, 'content': <*PostContent: content of the post>, 'attachlink': <string: URL of the page showing attachments>}
						NSString *route = [reqInfo objectAtIndex:2];
						NSString *board = [reqInfo objectAtIndex:3];
						id dict = [self.parser objectWithData:data];
						if ([dict isKindOfClass:[NSDictionary class]]) {
							[self.delegate showDigest:dict WithRoute:route OnBoard:board ForController:controller];
							return;
						}
						[self.delegate printContent:@"DATA CORRUPTED"];
						return;
					}
					case BBS_QUOTE_VIEW:
					{
						// {"content": <string: Post content encoded in Base64>, "name": <string: Attachment name>}
						NSString *board = [reqInfo objectAtIndex:2];
						NSNumber *postid = [reqInfo objectAtIndex:3];
						NSNumber *xid = [reqInfo objectAtIndex:4];
						id dict = [self.parser objectWithData:data];
						if ([dict isKindOfClass:[NSDictionary class]]) {
							[self.delegate showQuote:dict OnBoard:board WithID:[postid unsignedIntegerValue] WithXID:[xid unsignedIntegerValue] ForController:controller];
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
