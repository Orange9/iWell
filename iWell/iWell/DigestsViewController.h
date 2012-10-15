//
//  DigestsViewController.h
//  iWell
//
//  Created by Wu Weiyi on 10/9/12.
//
//

#import "ListViewController.h"

@interface DigestsViewController : ListViewController

@property (strong, nonatomic) NSMutableDictionary *digestsViewControllers;

@property (strong, nonatomic) NSString *board;
@property (strong, nonatomic) NSString *route;

@property (assign, nonatomic) NSInteger index;

- (void)updateDigests:(NSArray *)digests;

@end
