//
//  WILCell.m
//  Wilson
//
//  Created by Patrick Quinn-Graham on 7/06/2014.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import "WILCell.h"
#import "WILFeedViewController.h"

@implementation WILCell

- (instancetype)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)voteDown:(id)sender {
    [self.delegate collectionViewControllerCellDidVoteDown:self];
}

- (IBAction)voteUp:(id)sender {
    [self.delegate collectionViewControllerCellDidVoteUp:self];
}

- (IBAction)play:(id)sender {
    [self.delegate collectionViewControllerCellSaidPlay:self];
}


@end
