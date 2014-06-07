//
//  WILRecordingManager.m
//  Wilson
//
//  Created by Patrick Quinn-Graham on 7/06/2014.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import "WILRecordingManager.h"

#import <Parse/Parse.h>

const NSString *kRecording = @"Recording";

@implementation WILRecordingManager

+(instancetype)sharedManager {
    static WILRecordingManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WILRecordingManager alloc] init];
    });
    return manager;
}


- (void)list:(void(^)(NSArray*,NSError*))completionHandler {
    PFQuery *query = [PFQuery queryWithClassName:@"Recording"];
    [query findObjectsInBackgroundWithBlock:completionHandler];
}

- (void)dataForRecording:(id)recording completionHandler:(void(^)(NSData*, NSError*))completionHandler {
    PFObject *object = recording;
    PFFile *file = [object objectForKey:@"audioFile"];
    [file getDataInBackgroundWithBlock:completionHandler];
}

- (void)uploadRecording:(NSString*)filePath withFilter:(NSString*)filter andDuration:(NSInteger)duration completionHandler:(void(^)(BOOL succeeded, NSError *error))completionHandler {
    PFObject *object = [PFObject objectWithClassName:@"Recording"];
    object[@"filterName"] = filter;
    object[@"duration"] = @(duration);
    object[@"user"] = [PFUser currentUser];
    object[@"audioFile"] = [PFFile fileWithName:@"random-guess" contentsAtPath:filePath];
    object[@"upVotes"] = @(0);
    object[@"downVotes"] = @(0);
    [object saveInBackgroundWithBlock:completionHandler];
}

- (void)vote:(WILRecordingVote)direction forRecordingID:(NSString*)recordingID completionHandler:(void(^)(BOOL succeeded, NSError *error))completionHandler {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Recording"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:recordingID block:^(PFObject *recording, NSError *error) {
        switch (direction) {
            case WILRecordingVoteDown:
                [recording incrementKey:@"downVotes"];
                break;
            case WILRecordingVoteUp:
                [recording incrementKey:@"upVotes"];
                break;
        }
        [recording saveInBackgroundWithBlock:completionHandler];
        
    }];
    
//    func myfunc(foo : (() -> ())?) {
//        foo?()
//    }
}

@end
