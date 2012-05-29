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

@class MasterViewController;
@class DetailViewController;
@class LoginViewController;

@interface Core : NSObject <BBSCoreDelegate> {
	
}

@property (retain, nonatomic) MasterViewController *boardsOutput;
@property (retain, nonatomic) NSMutableDictionary *postsOutputs;
@property (retain, nonatomic) DetailViewController *contentOutput;
@property (retain, nonatomic) LoginViewController *loginInput;

- (NSString *)address;
- (NSString *)username;
- (NSString *)password;

- (NSDictionary *)boardInfoAtIndex:(NSUInteger)index;
- (NSDictionary *)postInfoAtIndex:(NSUInteger)index onBoard:(NSString *)board;
- (NSString *)boardNameAtIndex:(NSUInteger)index;
- (NSUInteger)postIDAtIndex:(NSUInteger)index onBoard:(NSString *)board;

- (NSUInteger)boardsCount;
- (NSUInteger)postsCountOnBoard:(NSString *)board;

- (void)connect:(NSString *)address withUsername:(NSString *)username Password:(NSString *)password;

- (void)listBoards;
- (void)listFavBoards;
- (void)listPostsOfBoard:(NSString *)board;
- (void)listNewerPostsOfBoard:(NSString *)board;
- (void)listOlderPostsOfBoard:(NSString *)board;
- (void)viewContentOfPost:(NSUInteger)postid onBoard:(NSString *)board;
- (void)viewContentOfNewerPost;
- (void)viewContentOfOlderPost;

@end


@interface View : UIScrollView <UIScrollViewDelegate> {
	
}

@property (strong, atomic) NSString *string;
@property (strong, nonatomic) StringConverter *converter;

- (void)blink;

@end
