//
//  PostViewController.h
//  iWell
//
//  Created by Wu Weiyi on 10/9/12.
//
//

#import "ListViewController.h"

#import "DigestsViewController.h"

@interface PostsViewController : ListViewController

@property (strong, nonatomic) DigestsViewController *digestViewController;

@property (assign, nonatomic) NSInteger index;

- (void)selectPostWithOffset:(NSInteger)offset;
- (void)updatePosts:(NSArray *)posts;

@end
