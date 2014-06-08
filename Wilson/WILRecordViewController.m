//
//  WILRecordViewController.m
//  Wilson
//
//  Created by Danny Ricciotti on 6/7/14.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import "WILRecordViewController.h"
#import "TPOscilloscopeLayer.h"
#import "WILPadView.h"
#import "WILAudioFilterPickerController.h"
#import "AERecorder.h"
#import "WILRecordingManager.h"

#import <DEBandPassFilter.h>
#import <DEDelayFilter.h>
#import <DEDistortionFilter.h>
#import <DEReverbFilter.h>
#import <DEDynamicsProcessorFilter.h>
#import <DEHighPassFilter.h>
#import <DEHighShelfFilter.h>
#import <DELowPassFilter.h>

#import <MBProgressHUD.h>

@interface WILRecordViewController ()

// Awesome Audio
@property (nonatomic, retain) AEAudioController *audioController;
@property (nonatomic, retain) AEAudioFilePlayer *loop1;
@property (nonatomic, retain) AEAudioFilePlayer *loop2;
@property (nonatomic, retain) AEBlockChannel *oscillator;
@property (nonatomic, retain) AEAudioUnitChannel *audioUnitPlayer;
@property (nonatomic) AEChannelGroupRef group;


// Oscilliscope UI
@property (nonatomic) UIView *oscilliscopeView;
@property (nonatomic, retain) TPOscilloscopeLayer *outputOscilloscope;
@property (nonatomic, retain) TPOscilloscopeLayer *inputOscilloscope;
@property (nonatomic, retain) CALayer *inputLevelLayer;
@property (nonatomic, retain) CALayer *outputLevelLayer;

// Recording
@property (nonatomic) NSString *recordingFilename;
@property (nonatomic, strong) AERecorder *recorder;
@property (nonatomic, retain) AEAudioFilePlayer *player;
@property (nonatomic) NSTimeInterval recordingDuration;

// Misc
@property (nonatomic, assign) NSTimer *levelsTimer;
@property (nonatomic, retain) UIButton *recordButton;
@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic, retain) UIButton *uploadButton;
@property (nonatomic, retain) UIButton *oneshotButton;
@property (nonatomic, retain) UIButton *oneshotAudioUnitButton;

@property (nonatomic, retain) UIButton *dismissButton;

// Pads
@property (nonatomic) NSArray *pads;
@property (nonatomic) NSMutableArray *loops;

// Filters
@property (nonatomic, strong) WILAudioFilterPickerController *filterPicker;
@property (nonatomic, strong) NSArray *customFilters;
@property (nonatomic, strong) AEAudioUnitFilter *currentAudioFilter; // retains current filter
@property (nonatomic, strong) NSDictionary *selectedFilter;
@property (nonatomic, strong) NSDictionary *lastRecordedFilter;

@end

@implementation WILRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self amazingSetup];
        
        self.loop1.channelIsMuted = NO;
        
        self.customFilters = @[@{@"name": @"Bandpass",
                                 @"filter": @(WILAudioFilterCustomBandPass)},
                               @{@"name": @"Distortion",
                                 @"filter": @(WILAudioFilterCustomDistortion)},
                               @{@"name": @"Delay",
                                 @"filter": @(WILAudioFilterCustomDelay)},
                               @{@"name": @"High Pass",
                                 @"filter": @(WILAudioFilterCustomHighPass)},
                               @{@"name": @"Low Pass",
                                 @"filter": @(WILAudioFilterCustomLowPass)},];
        
    }
    return self;
}

- (void)amazingSetup
{
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES];
    self.audioController.preferredBufferDuration = 0.005;
    [self.audioController start:NULL];
    
    
    NSArray *loops = @[@"Southern Rock Drums", @"Southern Rock Organ", @"drum", @"snapper"];
    NSArray *extensions = @[@"m4a", @"m4a", @"wav",@"wav"];
    
    self.loops = [NSMutableArray new];
    
    [loops enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
        
        AEAudioFilePlayer *loop = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:filename withExtension:[extensions objectAtIndex:idx]]
                                               audioController:_audioController
                                                         error:NULL];
        loop.volume = 1.0;
        loop.channelIsMuted = YES;
        loop.loop = YES;
        
        [self.loops addObject:loop];
        
    }];
        
    
    // Create an audio unit channel (a file player)
    self.audioUnitPlayer = [[AEAudioUnitChannel alloc] initWithComponentDescription:AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer)
                                                                     audioController:_audioController
                                                                               error:NULL];
    
    // Create a group for loop1, loop2 and oscillator
    self.group = [_audioController createChannelGroup];
    [_audioController addChannels:self.loops toChannelGroup:self.group];
    
    // Finally, add the audio unit player
    [_audioController addChannels:@[_audioUnitPlayer]];
    
    static const int kInputChannelsChangedContext;
    
    [_audioController addObserver:self forKeyPath:@"numberOfInputChannels" options:0 context:(void*)&kInputChannelsChangedContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor blackColor];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record-background"]];
    iv.frame = self.view.bounds;
    [self.view addSubview:iv];
    
    [self scopeUISetup];
    [self padViewSetup];
    [self audioFilterPickerSetup];
    [self playbackButtonSetup];
}

#pragma mark - Recording

- (void)playbackButtonSetup {
    
    // record button
    self.recordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [_recordButton setTitle:@"Stop" forState:UIControlStateSelected];
    [_recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    _recordButton.frame = CGRectMake(0, 300, 100, 44);
    _recordButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    
    // play button
    self.playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    [_playButton setTitle:@"Stop" forState:UIControlStateSelected];
    [_playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    _playButton.frame = CGRectMake(110,300,100,44);
    _playButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    
    // upload button
    self.uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
    [self.uploadButton addTarget:self action:@selector(uploadAndDismiss) forControlEvents:UIControlEventTouchUpInside];
    self.uploadButton.frame = CGRectMake(220,300,100,44);
    self.uploadButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    
    
    // dismiss button
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    self.dismissButton.frame = CGRectMake(110,350,100,44);
    self.dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;

    
    [self.view addSubview:self.recordButton];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.uploadButton];
    [self.view addSubview:self.dismissButton];
}

- (void)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)record:(id)sender {
    
    if ( _recorder ) {
        
        // save
        [_recorder finishRecording];
        [_audioController removeOutputReceiver:_recorder];
        [_audioController removeInputReceiver:_recorder];
        _recordButton.selected = NO;
        
        self.lastRecordedFilter = self.selectedFilter;
        self.recordingDuration = self.recorder.currentTime;
        
        self.recorder = nil;
        
    } else {
        
        if (!self.recordingFilename) {
            NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [documentsFolders[0] stringByAppendingPathComponent:@"Recording.aiff"];
            
            self.recordingFilename = path;
        }
        
        // start recording
        self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
        
        NSError *error = nil;
        if ( ![_recorder beginRecordingToFileAtPath:self.recordingFilename fileType:kAudioFileAIFFType error:&error] ) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
            self.recorder = nil;
            return;
        }
        
        _recordButton.selected = YES;
        
        [_audioController addOutputReceiver:_recorder];
        [_audioController addInputReceiver:_recorder];
    }
}


- (void)play:(id)sender {
    if ( _player ) {
        [_audioController removeChannels:@[_player]];
        self.player = nil;
        _playButton.selected = NO;
    } else {
        NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [documentsFolders[0] stringByAppendingPathComponent:@"Recording.aiff"];
        
        if ( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) return;
        
        NSError *error = nil;
        self.player = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL fileURLWithPath:path] audioController:_audioController error:&error];
        
        if ( !_player ) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                         message:[NSString stringWithFormat:@"Couldn't start playback: %@", [error localizedDescription]]
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:@"OK", nil] show];
            return;
        }
        
        _player.loop = YES;
//        _player.removeUponFinish = YES;
//        _player.completionBlock = ^{
//            _playButton.selected = NO;
//            self.player = nil;
//        };
        [_audioController addChannels:@[_player]];
        
        _playButton.selected = YES;
    }
}

- (void)uploadAndDismiss {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    [hud show:YES];
    
    hud.labelText = @"Submitting to Wilson!";
    
    NSLog(@"beginning upload..");
    
    NSString *filterName = [self.lastRecordedFilter objectForKey:@"name"];
    if (!filterName) {
        filterName = [self.selectedFilter objectForKey:@"name"];
    }
    if (!filterName) {
        filterName = @"Wilson";
    }
    
    [self recordingFinishedSuccess:self.recordingFilename duration:self.recordingDuration filterName:filterName completion:^(BOOL succeeded, NSError *error) {
        
        hud.labelText = @"Done!";
        [hud hide:YES afterDelay:0.5];
        
        if (error) {
            NSLog(@"upload failed: %@",error);
        } else {
            NSLog(@"upload complete!!");
            [self dismiss];
        }
        
    }];
    
}


- (void)recordingFinishedSuccess:(NSString *)filename duration:(NSTimeInterval)duration filterName:(NSString *)filterName completion:(void (^)(BOOL succeeded, NSError *error))completionBlock
{
    if (filename && filterName && duration != 0) {
        [[WILRecordingManager sharedManager] uploadRecording:filename withFilter:filterName andDuration:duration completionHandler:completionBlock];
    } else {
        NSLog(@"missing data!");
        if (completionBlock) {
            NSError *error = [[NSError alloc] initWithDomain:@"Wilson" code:22 userInfo:nil];
            completionBlock(NO, error);
        }
    }
    
}

- (void)dealloc {
    [self.filterPicker removeObserver:self forKeyPath:@"selectedFilter"];
    [_audioController removeObserver:self forKeyPath:@"numberOfInputChannels"];
}

#pragma mark - Oscilliscope

- (void)scopeUISetup
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    headerView.backgroundColor = [UIColor blackColor];
    
    self.outputOscilloscope = [[TPOscilloscopeLayer alloc] initWithAudioController:_audioController];
    _outputOscilloscope.frame = CGRectMake(0, 0, headerView.bounds.size.width, CGRectGetHeight(headerView.frame));
    [headerView.layer addSublayer:_outputOscilloscope];
    [_audioController addOutputReceiver:_outputOscilloscope];
    [_outputOscilloscope start];
    
    self.inputOscilloscope = [[TPOscilloscopeLayer alloc] initWithAudioController:_audioController];
    _inputOscilloscope.frame = CGRectMake(0, 0, headerView.bounds.size.width, CGRectGetHeight(headerView.frame));
    _inputOscilloscope.lineColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    [headerView.layer addSublayer:_inputOscilloscope];
    [_audioController addInputReceiver:_inputOscilloscope];
    [_inputOscilloscope start];
    
    self.inputLevelLayer = [CALayer layer];
    _inputLevelLayer.backgroundColor = [[UIColor colorWithWhite:0.0 alpha:0.3] CGColor];
    _inputLevelLayer.frame = CGRectMake(headerView.bounds.size.width/2.0 - 5.0 - (0.0), 90, 0, 10);
    [headerView.layer addSublayer:_inputLevelLayer];
    
    self.outputLevelLayer = [CALayer layer];
    _outputLevelLayer.backgroundColor = [[UIColor colorWithWhite:0.0 alpha:0.3] CGColor];
    _outputLevelLayer.frame = CGRectMake(headerView.bounds.size.width/2.0 + 5.0, 90, 0, 10);
    [headerView.layer addSublayer:_outputLevelLayer];
    
    [self.view addSubview:headerView];
    
    self.oscilliscopeView = headerView;
}

#pragma mark - Beat Pads


- (void)padViewSetup
{
    static const NSInteger kColCount = 4;
    static const CGFloat kPadSize = 320/kColCount;
    
    UIView *padView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.oscilliscopeView.frame), 320, kPadSize)];
    
    for ( NSInteger i = 0; i < 4; i ++ ) {
        WILPadView *pad = [[WILPadView alloc] initWithFrame:CGRectMake(i * kPadSize, 0, kPadSize, kPadSize)];
        pad.tag = i;
        pad.frame = UIEdgeInsetsInsetRect(pad.frame, UIEdgeInsetsMake(4, 4, 4, 4));
        [padView addSubview:pad];
        
        [pad addTarget:self action:@selector(padWasTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    [self.view addSubview:padView];
}

- (void)padWasTapped:(WILPadView *)pad
{
    AEAudioFilePlayer *loop = [self.loops objectAtIndex:pad.tag];
    NSParameterAssert(loop);
    
    pad.turnedOn = !pad.turnedOn;
    loop.channelIsMuted = !pad.turnedOn;
}

#pragma mark - Audio Filter

- (void)audioFilterPickerSetup {
    
    self.filterPicker = [[WILAudioFilterPickerController alloc] initWithCollectionViewLayout:[WILAudioFilterPickerController preferredLayout]];
    
    self.filterPicker.filters = self.customFilters;
    [self.filterPicker addObserver:self forKeyPath:@"selectedFilter" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addChildViewController:self.filterPicker];
    
    CGFloat collectionHeight = [WILAudioFilterPickerController preferredHeight];
    self.filterPicker.view.frame = CGRectMake(0,
                                         CGRectGetHeight(self.view.bounds) - collectionHeight,
                                         CGRectGetWidth(self.view.bounds),
                                         collectionHeight);
    
    [self.view addSubview:self.filterPicker.view];
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"selectedFilter"]) {
        NSDictionary *filter = [change objectForKey:@"new"];
        [self changeAudioFilterWithFilterData:filter];
        self.selectedFilter = filter;
    }
    
}

#pragma mark - Public Methods

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods

- (void)changeAudioFilterWithFilterData:(NSDictionary *)filterData {
    
    // get new filter
    AEAudioUnitFilter *newFilter;
    WILAudioFilter customFilter = [[filterData objectForKey:@"filter"] integerValue];
    
    switch (customFilter) {
        case WILAudioFilterCustomBandPass:
            newFilter = [DEBandpassFilter filterWithAudioController:self.audioController];
            break;
            
        case WILAudioFilterCustomDistortion:
            newFilter = [DEDistortionFilter filterWithAudioController:self.audioController];
            break;
            
        case WILAudioFilterCustomDelay:
            newFilter = [DEDelayFilter filterWithAudioController:self.audioController];
            break;
            
        case WILAudioFilterCustomHighPass:
            newFilter = [DEHighPassFilter filterWithAudioController:self.audioController];
            break;
            
        case WILAudioFilterCustomLowPass:
            newFilter = [DELowPassFilter filterWithAudioController:self.audioController];
            break;
            
        case WILAudioFilterNone:
            NSParameterAssert(NO); // impossible case | coding error
            break;
    }
    
    // if there is a new filter, remove the old & add it
    // else just remove old
    if ([self.currentAudioFilter class] != [newFilter class]) {
        
        [self.audioController removeFilter:self.currentAudioFilter];
        
        self.currentAudioFilter = newFilter;
        
        [self.audioController addFilter:self.currentAudioFilter];
        
    } else if (self.currentAudioFilter) {
        [self.audioController removeFilter:self.currentAudioFilter];
        self.currentAudioFilter = nil;
    }
    
    NSLog(@"self.audioController.filters: %@",self.audioController.filters);
}

@end
