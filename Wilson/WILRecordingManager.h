//
//  WILRecordingManager.h
//  Wilson
//
//  Created by Patrick Quinn-Graham on 7/06/2014.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WILRecordingVote) {
    WILRecordingVoteDown,
    WILRecordingVoteUp
};

@interface WILRecordingManager : NSObject

+(instancetype)sharedManager;

- (void)list:(void(^)(NSArray*,NSError*))completionHandler;

- (void)dataForRecording:(id)recording completionHandler:(void(^)(NSData*, NSError*))completionHandler;

- (void)uploadRecording:(NSString*)filePath withFilter:(NSString*)filter andDuration:(NSInteger)duration completionHandler:(void(^)(BOOL succeeded, NSError *error))completionHandler;

- (void)vote:(WILRecordingVote)direction forRecordingID:(NSString*)recordingID completionHandler:(void(^)(BOOL succeeded, NSError *error))completionHandler;

@end
