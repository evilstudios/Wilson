//
//  DRViewController.m
//  audio
//
//  Created by Danny Ricciotti on 9/9/12.
//  Copyright (c) 2012 Danny Ricciotti. All rights reserved.
//

#import "WILAudioRecordController.h"

///////////////////////////////////////////////////////////////

static const NSTimeInterval kPowerSampleFrequency = 0.1;
static const NSTimeInterval kPowerAnimationDuration = 0.09; // slightly less than kPowerSampleFrequency

///////////////////////////////////////////////////////////////

@interface WILAudioRecordController ()

// recording
- (void)_beginRecording;
- (void)_pauseRecording;
- (void)_saveRecording;
- (void)_stopRecording;
- (void)_updateRecordButtonUIState;

// playback
- (void)_updatePlayButtonUIState;

// power sampling
- (void)_setAudioPowerSamplingEnabled:(BOOL)enabled;

// map
//- (void)_locationWasUpdated:(NSNotification *)notification;
- (void)_mapWasTapped:(UITapGestureRecognizer *)tapGestureRecognizer;

- (void)_setRecordControlsHidden:(BOOL)hidden animated:(BOOL)animated delay:(NSTimeInterval)delay;
- (void)_setExtraControlsHidden:(BOOL)hidden animated:(BOOL)animated delay:(NSTimeInterval)delay;
- (void)_setAllControlsHidden:(BOOL)hidden animated:(BOOL)animated delay:(NSTimeInterval)delay;

@property (strong) AVAudioPlayer *audioPlayer;
@property (strong) AVAudioRecorder *audioRecorder;
@property (strong) NSTimer *powerSamplingTimer;
@property (strong) NSString *filenameUniqueString;

@end

static const NSString *kDRAudioFileType = @"aif";
static const NSTimeInterval kDRMinRecordingLength = 1;

///////////////////////////////////////////////////////////////

@implementation WILAudioRecordController
@synthesize recordButton = _recordButton;
@synthesize playButton = _playButton;
@synthesize saveButton = _saveButton;
@synthesize audioPlayer = _audioPlayer;
@synthesize audioRecorder = _audioRecorder;
@synthesize power0View = _power0View;
@synthesize powerSamplingTimer = _powerSamplingTimer;

///////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self != nil )
    {
        self.filenameUniqueString = [NSString stringWithFormat:@"%d-%d.%@", arc4random(), arc4random(), kDRAudioFileType];
        
        // random filename is use to avoid collision with older recordings
        NSString *filename = [NSString stringWithFormat:@"live-%@", self.filenameUniqueString];
        
        /// create sound file
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = dirPaths[0];
        NSString *soundFilePath = [docsDir stringByAppendingPathComponent:filename];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        
        // recording settings
        NSDictionary *recordSettings = @{AVEncoderAudioQualityKey: @(AVAudioQualityHigh),
                                        AVEncoderBitRateKey: @24,
                                        AVNumberOfChannelsKey: @1,
                                        AVSampleRateKey: @24000.0f};
        
        // create recorder
        NSError *error = nil;
        
        self.audioRecorder = [[AVAudioRecorder alloc]
                              initWithURL:soundFileURL
                              settings:recordSettings
                              error:&error];
        
        NSParameterAssert(self.audioRecorder);
        
        /// todo audiorecorder delegate methods not being called!
        self.audioRecorder.delegate = self;
        self.audioRecorder.meteringEnabled = YES;
        
        if (error)
        {
            NSLog(@"error: %@", [error localizedDescription]);
            
        } else {
            BOOL success = [self.audioRecorder prepareToRecord];
            if ( ! success )
            {
//                NSString *str = [NSString stringWithFormat:@"Error: %@ : %d", [@__FILE__ lastPathComponent], __LINE__];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [self.powerSamplingTimer invalidate];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _setAudioPowerSamplingEnabled:YES];
    
//    [[DRAudioPlayer sharedAudioPlayer] pausePlaying];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self _setAudioPowerSamplingEnabled:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _samplePowerAndUpdateUI];
    [self _updateRecordButtonUIState];
    [self _updatePlayButtonUIState];
    
    [self _setExtraControlsHidden:YES animated:NO delay:0.0];
    [self _setRecordControlsHidden:NO animated:NO delay:0.0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSError *error;
    AVAudioSession *session = [AVAudioSession sharedInstance];

    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if ( error != nil )
    {
//        NSString *str = [NSString stringWithFormat:@"Error: %@ : %d %@", [@__FILE__ lastPathComponent], __LINE__, error];
    }
}

#pragma mark -
#pragma mark AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"%s called", __FUNCTION__);
    /// todo handle error
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
//    NSString *str = [NSString stringWithFormat:@"Error: %@ : %d", [@__FILE__ lastPathComponent], __LINE__];
//    NSLog(@"%s called", __FUNCTION__);
    /// todo error encoding
}

// todo audioRecorderBeginInterruption  

#pragma mark -
#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"%s called. Succes = %@", __FUNCTION__, flag ? @"YES":@"NO");
    [self _stopPlayback];
    // todo handle error
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"%s called", __FUNCTION__);
    [self _stopPlayback];
    // todo handle error
}

#pragma mark -
#pragma mark Public

- (IBAction)recordButtonWasPressed:(id)sender
{
    [self _stopPlayback];
    
    if ( self.audioRecorder.isRecording == NO )
    {
        [self _beginRecording];
        [self _setExtraControlsHidden:YES animated:YES delay:0.0];
    }
    else
    {
        [self _pauseRecording];
        [self _setExtraControlsHidden:NO animated:YES delay:0.0];
    }
}

- (IBAction)saveButtonWasPressed:(id)sender
{
    [self _saveRecording];
}

- (IBAction)playButtonWasPressed:(id)sender
{
    NSLog(@"%s called", __FUNCTION__);
    
    if ( self.audioPlayer.isPlaying == YES )
    {
        [self _stopPlayback];
    }
    else
    {
        [self _beginPlayback];
    }
}

#pragma mark -
#pragma mark Recording

- (void)_beginRecording
{
    NSParameterAssert(self.audioRecorder);
    BOOL success = [self.audioRecorder record];
    NSParameterAssert(success);
    if ( success == NO )
    {
//        NSString *str = [NSString stringWithFormat:@"Error: %@ : %d", [@__FILE__ lastPathComponent], __LINE__];
//        [UIAlertView DRAlertViewWithString:str];
        /// todo error
    }
    [self _updateRecordButtonUIState];
}

- (void)_pauseRecording
{
    NSLog(@"%s called", __FUNCTION__);
    
    if ( self.audioRecorder.isRecording == YES )
    {
        [self.audioRecorder pause];
    }
    [self _updateRecordButtonUIState];
}

- (void)_stopRecording
{
    NSLog(@"%s called", __FUNCTION__);
    [self.audioRecorder stop];
    [self _updateRecordButtonUIState];
}

- (void)_saveRecording
{
    NSLog(@"Saving recording...");

    [self _stopRecording];
    [self _updateRecordButtonUIState];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.audioRecorder.url options:nil];
    CMTime time = asset.duration;
    NSTimeInterval recordingLength = CMTimeGetSeconds(time);
    
    if ( recordingLength < kDRMinRecordingLength )
    {
        NSLog(@"Recording too short (%f sec)", recordingLength);
        return;
    }
    else
    {
        NSLog(@"Audio recording length is %f sec", recordingLength);
    }
    
    // save the url of the audio file
    NSURL *url = [self.audioRecorder url];
    NSParameterAssert(url);
    
    
    // TODO: stuff.
    
}

#pragma mark -
#pragma mark Playback

- (void)_beginPlayback
{    
    [self _stopRecording];
    
    if ( self.audioPlayer == nil )
    {
        
        NSError *error;
        
        self.audioPlayer = [[AVAudioPlayer alloc] 
                            initWithContentsOfURL:self.audioRecorder.url                                    
                            error:&error];
        self.audioPlayer.meteringEnabled = YES;
        if (error)
        {
            NSLog(@"Error: %@", [error localizedDescription]);
            self.audioPlayer = nil;
            return;
        }
        self.audioPlayer.delegate = self;
    }
    
    [self.audioPlayer play];
    [self _updatePlayButtonUIState];
}

- (void)_stopPlayback
{
    [self.audioPlayer stop];
    [self _updatePlayButtonUIState];
}

- (void)_pausePlayback
{
    [self.audioPlayer stop];
    [self _updatePlayButtonUIState];
}

#pragma mark -
#pragma mark Power sampling

- (void)_setAudioPowerSamplingEnabled:(BOOL)enabled
{
    if (( enabled == YES ) && ( self.powerSamplingTimer == nil ))
    {
        self.powerSamplingTimer = [NSTimer scheduledTimerWithTimeInterval:kPowerSampleFrequency target:self selector:@selector(_samplePowerAndUpdateUI) userInfo:nil repeats:YES];
    }
    else if (( enabled == NO ) && ( self.powerSamplingTimer != nil ))
    {
        [self.powerSamplingTimer invalidate];
        self.powerSamplingTimer = nil;
    }
    
    [self _samplePowerAndUpdateUI];
}

- (void)_updatePlayButtonUIState
{
    BOOL isPlaying = NO;
    if ( self.audioPlayer != nil )
    {
        isPlaying = self.audioPlayer.isPlaying;
    }
    
    if ( isPlaying == YES )
    {
        [self.playButton setImage:[UIImage imageNamed:@"pause-icon"] forState:UIControlStateNormal];
    }
    else
    {
        [self.playButton setImage:[UIImage imageNamed:@"play-icon"] forState:UIControlStateNormal];
    }
}

- (void)_updateRecordButtonUIState
{
    BOOL isRecording = NO;
    if ( self.audioRecorder != nil )
    {
        isRecording = self.audioRecorder.isRecording;
    }
    
    if ( isRecording == YES )
    {
        [self.recordButton setImage:[UIImage imageNamed:@"pause-icon"] forState:UIControlStateNormal];
    }
    else
    {
        [self.recordButton setImage:[UIImage imageNamed:@"record-icon"] forState:UIControlStateNormal];
    }
}

- (void)_samplePowerAndUpdateUI
{
    static const CGFloat kMinDB = -60.0f;
    static const CGFloat kMaxDB = 0.0f;
    static const CGFloat kRangeDB = 60.0f;
    static const CGFloat kHeightBarFull = 63.0;
    
    float power = 0.0f  ;
    UIColor *barColor;
    BOOL isHidden = NO;
    
    if ( self.audioRecorder.isRecording == YES )
    {    
        // audio value is between -160db (silent) and 0db (full scale)
        /// @see https://developer.apple.com/library/ios/#documentation/AVFoundation/Reference/AVAudioRecorder_ClassReference/Reference/Reference.html
        [self.audioRecorder updateMeters];
        power = [self.audioRecorder averagePowerForChannel:0];
        barColor = [UIColor redColor];
        
        NSLog(@"Audio Power is %f", power);
    }
    else if ( self.audioPlayer.isPlaying == YES )
    {
        [self.audioPlayer updateMeters];
        power = [self.audioPlayer averagePowerForChannel:0];
        barColor = [UIColor blackColor];
    }
    else
    {
        isHidden = YES;
        // not recording. show no bars
    }
    
    self.power0View.hidden = isHidden;
    if ( isHidden == NO )
    {
        self.power0View.backgroundColor = barColor;
        
        power = MAX(MIN(power, kMaxDB), kMinDB) + kRangeDB;
        CGFloat powerBarHeight = (power / kRangeDB) * kHeightBarFull;
        CGRect powerFrame = CGRectMake(0,self.power0View.frame.origin.y,self.view.frame.size.width,powerBarHeight);
        
        [UIView animateWithDuration:kPowerAnimationDuration
                         animations:^{
                             self.power0View.frame = powerFrame;
                         }
                         completion:nil];
    }
}

- (void)_setAllControlsHidden:(BOOL)hidden animated:(BOOL)animated delay:(NSTimeInterval)delay
{
    [self _setRecordControlsHidden:hidden animated:animated delay:delay];
    [self _setExtraControlsHidden:hidden animated:animated delay:delay];
}

- (void)_setRecordControlsHidden:(BOOL)hidden animated:(BOOL)animated delay:(NSTimeInterval)delay
{
    [UIView animateWithDuration:animated ? 0.25 : 0.0
                          delay:delay
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGFloat newy;
                         if ( hidden == YES )
                         {
                             newy = self.view.frame.size.height + self.recordButton.frame.size.height;
                         }
                         else
                         {
                             newy = self.view.frame.size.height - self.recordButton.frame.size.height/2 - 5; // 5 padding
                         }
                         
                         self.recordButton.center = CGPointMake(self.view.frame.size.width / 2, newy);
                         
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
}

- (void)_setExtraControlsHidden:(BOOL)hidden animated:(BOOL)animated delay:(NSTimeInterval)delay
{
    CGFloat newy;
    if ( hidden == YES )
    {
        newy = self.view.frame.size.height + self.playButton.frame.size.height;
    }
    else
    {
        newy = self.view.frame.size.height - self.playButton.frame.size.height/2 - 5; // 5 padding
    }
    [UIView animateWithDuration:animated ? 0.25 : 0.0
                          delay:delay
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.playButton.center = CGPointMake(self.playButton.center.x, newy);
                     }
                     completion:nil];
    [UIView animateWithDuration:animated ? 0.25 : 0.0
                          delay:animated ? (delay + .05) : delay
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.saveButton.center = CGPointMake(self.saveButton.center.x, newy);
                     }
                     completion:nil];

}

@end
