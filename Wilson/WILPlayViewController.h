//
//  WILPlayViewController.h
//  Wilson
//
//  Created by Danny Ricciotti on 6/7/14.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WILPlayViewController : UIViewController


- (void)play:(PFObject *)object;
- (void)stopPlaying;

@property (nonatomic, retain) AEAudioController *audioController;


@end
