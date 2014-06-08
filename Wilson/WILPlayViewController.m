//
//  WILPlayViewController.m
//  Wilson
//
//  Created by Danny Ricciotti on 6/7/14.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import "WILPlayViewController.h"
#import "WILRecordingManager.h"
#import "TPOscilloscopeLayer.h"

@interface WILPlayViewController ()

@property (nonatomic, retain) AEAudioFilePlayer *loop;
@property (nonatomic) PFObject *object;

@property (nonatomic, retain) TPOscilloscopeLayer *oscilliscope;

@end

@implementation WILPlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:NO];
        self.audioController.preferredBufferDuration = 0.005;
        [self.audioController start:NULL];          // ??
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupOss];
}

#pragma mark - Public

- (void)play:(PFObject *)object
{
    NSParameterAssert(object);
    
    
    self.object = object;
    
    
    
    [[WILRecordingManager sharedManager] dataForRecording:object completionHandler:^(NSData *data, NSError *error) {
        if ( error ) {
            NSLog(@"Error loading audio: %@ ", error);
            return;
        }
        
        
        if ( [object isEqual:self.object] ) {
        
            [self loopIt:data];
            
        }
        
    }];
    
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

-(NSString *) writeToTextFile:(NSData *)data
{
    NSString *path = [[self applicationDocumentsDirectory].path
                      stringByAppendingPathComponent:@"playingloop.aif"];
    [data writeToFile:path atomically:YES];
    return path;
}

- (void)loopIt:(NSData *)data
{
    if ( self.loop ) {
        [self.audioController removeChannels:@[self.loop]];
    }
    
    NSString *str = [self writeToTextFile:data];
    NSParameterAssert(str);

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AEAudioFilePlayer *loop = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL fileURLWithPath:str]
                                                            audioController:self.audioController
                                                                      error:NULL];
        NSParameterAssert(loop);
        NSLog(@"File is %@", str);
        if ( !loop ) {
            NSLog(@"error loading loop");
            return;
        }
        loop.volume = 1.0;
        loop.channelIsMuted = NO;
        loop.loop = YES;
        
        [self.audioController addChannels:@[loop]];
        self.loop = loop;
        
        self.oscilliscope.frame = self.view.bounds; // HACK to get frame right. no autoresizing on this CALayer :( todo
       
        [self.audioController start:NULL];

    });
}

- (void)stopPlaying
{
    [self.audioController stop];
}

- (void)setupOss
{
    self.oscilliscope = [[TPOscilloscopeLayer alloc] initWithAudioController:_audioController];
    _oscilliscope.frame = self.view.bounds;
    _oscilliscope.lineColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    [self.view.layer addSublayer:_oscilliscope];
    [_audioController addOutputReceiver:self.oscilliscope];
    [_oscilliscope start];
}


@end
