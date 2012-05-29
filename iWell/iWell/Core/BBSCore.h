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

- (void)online;
- (void)printContent:(NSString *)content;
- (void)showContent:(NSDictionary *)content inBoard:(NSString *)board withID:(NSUInteger)postid;
- (void)showPosts:(NSArray *)posts inBoard:(NSString *)board;
- (void)showBoards:(NSArray *)boards;

@end

enum bbs_stage_t {
	BBS_IDLE,
	
	BBS_OAUTH_ACCESS,
	BBS_OAUTH_ACCESS_RECV,
	BBS_OAUTH_SESSION,
	BBS_OAUTH_SESSION_RECV,
	
	BBS_ONLINE,
};

enum bbs_req_t {
	BBS_BOARDS_LIST,
	BBS_FAVBOARDS_LIST,
	
	BBS_POSTS_LIST,
	
	BBS_CONTENT_VIEW,
};

@interface BBSCore : NSObject <NetCoreDelegate> {
	
}

@property (assign, nonatomic) id<BBSCoreDelegate> delegate;

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

- (void)connect;
- (void)disconnect;

- (void)listBoardsInRange:(NSRange)range;
- (void)listFavBoardsInRange:(NSRange)range;
- (void)listPostsInRange:(NSRange)range onBoard:(NSString *)board;
- (void)viewContentOfPost:(NSUInteger)postid onBoard:(NSString *)board;

@end
