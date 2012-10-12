//
//  Core_Pad.h
//  iWell-Pad
//
//  Created by Wu Weiyi on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBSCore.h"
#import "StringConverter.h"
#import "PreferenceStorage.h"

@class BoardsViewController;
@class ContentViewController;
@class LoginViewController;
@class PostEditViewController;

@interface Core : NSObject <BBSCoreDelegate> {
	
}

@property (retain, nonatomic) BoardsViewController *boardsOutput;
@property (retain, nonatomic) ContentViewController *contentOutput;
@property (retain, nonatomic) PostEditViewController *postInput;
@property (retain, nonatomic) LoginViewController *loginInput;

- (NSString *)address;

- (NSDictionary *)boardInfoAtIndex:(NSUInteger)index;
- (NSDictionary *)postInfoAtIndex:(NSUInteger)index onBoard:(NSString *)board;
- (NSString *)boardNameAtIndex:(NSUInteger)index;
- (NSUInteger)postIDAtIndex:(NSUInteger)index onBoard:(NSString *)board;
- (NSUInteger)newestPostIDAtIndexOnBoard:(NSString *)board;
- (NSUInteger)oldestPostIDAtIndexOnBoard:(NSString *)board;

- (NSUInteger)boardsCount;
- (NSUInteger)postsCountOnBoard:(NSString *)board;

- (void)OAuth:(NSString *)address;
- (void)connectWithToken:(NSString *)token;
- (void)resume;

- (void)listBoards;
- (void)listFavBoards;
- (void)listPostsOfBoard:(NSString *)board;
- (void)listNewerPostsOfBoard:(NSString *)board;
- (void)listOlderPostsOfBoard:(NSString *)board;
- (void)listPostsNear:(NSUInteger)postid onBoard:(NSString *)board;
- (void)viewContentOfPost:(NSUInteger)postid onBoard:(NSString *)board;
- (void)viewContentOfNewerPost;
- (void)viewContentOfOlderPost;
- (void)viewQuoteOfPost:(NSUInteger)postid onBoard:(NSString *)board WithXID:(NSUInteger)xid;
- (void)post:(NSString *)content WithTitle:(NSString *)title onBoard:(NSString *)board WithID:(NSUInteger)postid WithXID:(NSUInteger)xid;

@end


@interface View : UIScrollView <UIScrollViewDelegate> {
	
}

@property (strong, atomic) NSString *string;
@property (strong, nonatomic) StringConverter *converter;

- (void)blink;

@end
