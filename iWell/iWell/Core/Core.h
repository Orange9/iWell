//
//  Core_Pad.h
//  iWell-Pad
//
//  Created by Wu Weiyi on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBSCore.h"
#import "PreferenceStorage.h"

@class BoardsViewController;
@class PostsViewController;
@class ContentViewController;
@class PostEditViewController;

@interface Core : NSObject <BBSCoreDelegate> {
	
}

@property (retain, nonatomic) BoardsViewController *boardsOutput;
@property (retain, nonatomic) ContentViewController *contentOutput;
@property (retain, nonatomic) PostEditViewController *postInput;

- (NSString *)address;

- (void)OAuth:(NSString *)address;
- (void)connectWithToken:(NSString *)token;
- (void)resume;

- (void)listBoardsForController:(BoardsViewController *)controller;
- (void)listFavBoardsForController:(BoardsViewController *)controller;
- (void)listPostsForController:(PostsViewController *)controller;
- (void)listPostsFrom:(NSInteger)startid To:(NSInteger)endid ForController:(PostsViewController *)controller;
- (void)viewContentForController:(ContentViewController *)controller;
- (void)viewQuoteForController:(PostEditViewController *)controller;
- (void)postForController:(PostEditViewController *)controller;

@end


