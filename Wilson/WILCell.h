//
//  WILCell.h
//  Wilson
//
//  Created by Patrick Quinn-Graham on 7/06/2014.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WILFeedViewController;
@class PFObject;

@interface WILCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *upVote;
@property (weak, nonatomic) IBOutlet UIButton *downVote;
@property (weak, nonatomic) IBOutlet UIButton *nameLabel;

@property (weak, nonatomic) WILFeedViewController *delegate;
@property (weak, nonatomic) PFObject *object;

@end
