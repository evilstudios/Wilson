//
//  WILAudioFilterPickerCell.m
//  Wilson
//
//  Created by Sean Conrad on 6/7/14.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import "WILAudioFilterPickerCell.h"

@interface WILAudioFilterPickerCell ()
@property (nonatomic, readwrite) UILabel *filterLabel;
@end

@implementation WILAudioFilterPickerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsetsMake(5, 5, 5, 5));
        self.contentView.backgroundColor = [UIColor redColor];
        self.contentView.layer.cornerRadius = 5;
        
        self.filterLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:self.filterLabel];
        
        self.filterLabel.textColor = [UIColor whiteColor];
        self.filterLabel.textAlignment = NSTextAlignmentCenter;
        
        self.filterLabel.font = [UIFont boldSystemFontOfSize:17];
        
    }
    return self;
}

- (void)layoutSubviews {
    self.contentView.alpha = (self.filterSelected) ? 0.5 : 1.0;
}

- (void)setFilterSelected:(BOOL)filterSelected {
    _filterSelected = filterSelected;
    [self setNeedsLayout];
}

@end
