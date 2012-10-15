//
//  BBSCore.h
//  iWell
//
//  Created by Wu Weiyi on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBJson.h"
#import "NetCore.h"

@protocol BBSCoreDelegate <NSObject>

- (void)online:(NSString *)token;
- (void)printContent:(NSString *)content;
- (void)showContent:(NSDictionary *)content OnBoard:(NSString *)board ForController:(id)controller;
- (void)showDigest:(NSDictionary *)content WithRoute:(NSString *)route OnBoard:(NSString *)board ForController:(id)controller;
- (void)showQuote:(NSDictionary *)content OnBoard:(NSString *)board WithID:(NSUInteger)postid WithXID:(NSUInteger)xid ForController:(id)controller;
- (void)showDigests:(NSArray *)digests ForController:(id)controller;
- (void)showPosts:(NSArray *)posts ForController:(id)controller;
- (void)showBoards:(NSArray *)boards ForController:(id)controller;

@end

enum bbs_stage_t {
	BBS_IDLE,
	
	BBS_OAUTH_SESSION,
	BBS_OAUTH_SESSION_RECV,
	BBS_OAUTH_VERIFY,
	BBS_OAUTH_VERIFY_RECV,
	
	BBS_ONLINE,
};

enum bbs_req_t {
	BBS_BOARDS_LIST,
	BBS_FAVBOARDS_LIST,
	
	BBS_POSTS_LIST,
	
	BBS_DIGEST_LIST,
	
	BBS_CONTENT_VIEW,
	
	BBS_DIGEST_VIEW,
	
	BBS_QUOTE_VIEW,
	
	BBS_POST,
};

@interface BBSCore : NSObject <NetCoreDelegate> {
	
}

@property (assign, nonatomic) id<BBSCoreDelegate> delegate;

@property (strong, nonatomic) NSURL *baseURL;

@property (strong, nonatomic) NSString *authorizationToken;
@property (strong, nonatomic) NSString *sessionToken;

- (void)OAuth;
- (void)connectWithStage:(enum bbs_stage_t)stage;
- (void)disconnect;

- (void)listBoardsInRange:(NSRange)range ForController:(id)controller;
- (void)listFavBoardsInRange:(NSRange)range ForController:(id)controller;
- (void)listPostsInRange:(NSRange)range OnBoard:(NSString *)board ForController:(id)controller;
- (void)listDigestInRange:(NSRange)range OnBoard:(NSString *)board WithRoute:(NSString *)route ForController:(id)controller;
- (void)viewContentOfPost:(NSUInteger)postid OnBoard:(NSString *)board ForController:(id)controller;
- (void)viewDigestWithRoute:(NSString *)route OnBoard:(NSString *)board ForController:(id)controller;
- (void)viewQuoteOfPost:(NSUInteger)postid OnBoard:(NSString *)board WithXID:(NSUInteger)xid ForController:(id)controller;
- (void)post:(NSString *)content WithTitle:(NSString *)title OnBoard:(NSString *)board WithID:(NSUInteger)postid WithXID:(NSUInteger)xid ForController:(id)controller;

@end
