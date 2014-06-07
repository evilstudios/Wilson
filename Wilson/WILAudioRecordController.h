//
//  DRViewController.h
//  audio
//
//  Created by Danny Ricciotti on 9/9/12.
//  Copyright (c) 2012 Danny Ricciotti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface WILAudioRecordController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *_audioRecorder;
    AVAudioPlayer *_audioPlayer;
    
    // controls
    UIButton *_recordButton;
    UIButton *_saveButton;
    UIButton *_playButton;
    UIButton *_locationButton;
    
    // power
    UIView *_power0View;
    NSTimer *_powerSamplingTimer;
}

@property IBOutlet UIView *power0View;

@property IBOutlet UIButton *locationButton;
@property IBOutlet UIButton *recordButton;
@property IBOutlet UIButton *saveButton;
@property IBOutlet UIButton *playButton;

- (IBAction)recordButtonWasPressed:(id)sender;
- (IBAction)saveButtonWasPressed:(id)sender;
- (IBAction)playButtonWasPressed:(id)sender;

@end
