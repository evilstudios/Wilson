//
//  WILRecordViewController.h
//  Wilson
//
//  Created by Danny Ricciotti on 6/7/14.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSUInteger, WILAudioFilter) {
    WILAudioFilterNone,
    WILAudioFilterCustomBandPass,
    WILAudioFilterCustomDelay,
    WILAudioFilterCustomDistortion,
    WILAudioFilterCustomHighPass,
    WILAudioFilterCustomLowPass
};

////////////////////////////////////////////////////////////////////////////////

@interface WILRecordViewController : UIViewController

@end
