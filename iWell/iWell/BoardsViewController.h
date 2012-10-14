//
//  BoardsViewController.h
//  iWell
//
//  Created by Wu Weiyi on 10/9/12.
//
//

#import "ListViewController.h"

enum LIST_TYPE {
	LIST_FAV,
	LIST_BOARD,
};

@interface BoardsViewController : ListViewController <UIAlertViewDelegate>

@property (assign, nonatomic) enum LIST_TYPE type;

@property (strong, nonatomic) NSMutableDictionary *postsViewControllers;

- (void)updateBoards:(NSArray *)boards;

@end
