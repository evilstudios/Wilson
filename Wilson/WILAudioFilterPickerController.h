//
//  WILAudioFilterPickerController.h
//  Wilson
//
//  Created by Sean Conrad on 6/7/14.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WILAudioFilterPickerController : UICollectionViewController

+ (UICollectionViewLayout *)preferredLayout;
+ (CGFloat)preferredHeight;

@property (nonatomic, strong) NSDictionary *selectedFilter;
@property (nonatomic, strong) NSArray *filters;

@end
