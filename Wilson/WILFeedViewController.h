//
//  WILFeedViewController.h
//  Wilson
//
//  Created by Patrick Quinn-Graham on 7/06/2014.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WILCell;

@interface WILFeedViewController : UICollectionViewController

- (instancetype)initWithStickyHeaderFlowLayout;

- (void)collectionViewControllerCellDidVoteDown:(WILCell*)cell;

- (void)collectionViewControllerCellDidVoteUp:(WILCell*)cell;

- (void)collectionViewControllerCellSaidPlay:(WILCell*)cell;

@end
