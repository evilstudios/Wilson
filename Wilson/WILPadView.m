//
//  WILPadView.m
//  Wilson
//
//  Created by Danny Ricciotti on 6/7/14.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import "WILPadView.h"

@implementation WILPadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.turnedOn = NO; // force call to custom setter
        
        self.layer.cornerRadius = 12;
    }
    return self;
}

- (void)setTurnedOn:(BOOL)turnedOn
{
    _turnedOn = turnedOn;
    
    self.backgroundColor = turnedOn ? [UIColor whiteColor] : [UIColor blueColor];
}

@end
