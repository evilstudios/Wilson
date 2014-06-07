//
//  WILCell.m
//  Wilson
//
//  Created by Patrick Quinn-Graham on 7/06/2014.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import "WILCell.h"
#import "WILFeedViewController.h"
#import <Parse/Parse.h>

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

- (void)setObject:(PFObject *)object {
    
    _object = object;
    
    [self.downVote setTitle:[NSString stringWithFormat:@"💩 %@", object[@"downVotes"]] forState:UIControlStateNormal];
    [self.upVote setTitle:[NSString stringWithFormat:@"❤️ %@", object[@"upVotes"]] forState:UIControlStateNormal];
    self.textLabel.text = object.objectId;
    
}

@end
