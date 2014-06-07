//
//  WILAudioFilterPickerController.h
//  Wilson
//
//  Created by Sean Conrad on 6/7/14.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AEAudioUnitFilter.h>

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSUInteger, WILAudioFilter) {
    WILAudioFilterNone,
    WILAudioFilterCustomDelay,
    WILAudioFilterCustomDistortion,
    WILAudioFilterCustomReverb,
    WILAudioFilterCustomVarispeed
};

////////////////////////////////////////////////////////////////////////////////

@interface WILAudioFilterPickerController : UICollectionViewController

+ (UICollectionViewLayout *)preferredLayout;
+ (CGFloat)preferredHeight;

@property (nonatomic) WILAudioFilter selectedFilter;

@end
