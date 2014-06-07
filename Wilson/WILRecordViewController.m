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


// Misc
@property (nonatomic, assign) NSTimer *levelsTimer;
//@property (nonatomic, retain) AERecorder *recorder;
@property (nonatomic, retain) AEAudioFilePlayer *player;
@property (nonatomic, retain) UIButton *recordButton;
@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic, retain) UIButton *oneshotButton;
@property (nonatomic, retain) UIButton *oneshotAudioUnitButton;

// Pads
@property (nonatomic) NSArray *pads;
@property (nonatomic) NSMutableArray *loops;


@end

@implementation WILRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self amazingSetup];
        
        self.loop1.channelIsMuted = NO;
    }
    return self;
}

- (void)amazingSetup
{
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES];
    self.audioController.preferredBufferDuration = 0.005;
    [self.audioController start:NULL];
    
    
    NSArray *loops = @[@"Southern Rock Drums", @"Southern Rock Organ"];
    
    self.loops = [NSMutableArray new];
    
    [loops enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
        
        AEAudioFilePlayer *loop = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:filename withExtension:@"m4a"]
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
    
    [self scopeUISetup];
    [self padViewSetup];

}

#pragma mark - Oscilliscope

- (void)scopeUISetup
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    headerView.backgroundColor = [UIColor darkGrayColor];
    
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
    
    loop.channelIsMuted = !loop.channelIsMuted;
}

@end
