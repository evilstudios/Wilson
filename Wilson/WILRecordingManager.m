//
//  WILRecordingManager.m
//  Wilson
//
//  Created by Patrick Quinn-Graham on 7/06/2014.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import "WILRecordingManager.h"

#import <Parse/Parse.h>

@implementation WILRecordingManager

+(instancetype)sharedManager {
    static WILRecordingManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WILRecordingManager alloc] init];
    });
    return manager;
}



@end
