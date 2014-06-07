//
//  WILAppDelegate.m
//  Wilson
//
//  Created by Danny Ricciotti on 6/7/14.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import <Parse/Parse.h>
#import "WILAppDelegate.h"
#import "WILAudioRecordController.h"
#import "WILFeedViewController.h"

@implementation WILAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"hQN9iXqr0K23bmE8dk64Z52JZzIf0VCaAKqHNLkH"
                  clientKey:@"aHSX67W4GoHhstgf8x18cIkiBxYJxMlvbsM6GShG"];
    
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
            NSLog(@"Anonymous login failed.");
        } else {
            NSLog(@"Anonymous user logged in.");
        }
    }];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
//    WILAudioRecordController *vc = [[WILAudioRecordController alloc] initWithNibName:nil bundle:nil];
    WILFeedViewController *vc = [[WILFeedViewController alloc] initWithStickyHeaderFlowLayout];
//    WILFeedViewController *other = [[WILFeedViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.window.rootViewController = vc;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
