//
//  WILFeedViewController.m
//  Wilson
//
//  Created by Patrick Quinn-Graham on 7/06/2014.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import "WILFeedViewController.h"
#import "WILFeedHeader.h"
#import "WILCell.h"

#import "WILRecordViewController.h"
#import "WILRecordingManager.h"

#import "CSStickyHeaderFlowLayout.h"
#import "MBProgressHUD.h"
#import "NSSortDescriptor+WilsonRank.h"
#import <Parse/Parse.h>
#import "WILPlayViewController.h"
#import "NSSortDescriptor+WilsonRank.h"

@interface WILFeedViewController ()

@property (nonatomic, strong) NSArray *recordings;
@property (nonatomic, strong) UINib *headerNib;
@property (nonatomic, strong) UINib *cellNib;
@property (nonatomic) WILPlayViewController *playController;

@end

@implementation WILFeedViewController

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)initWithStickyHeaderFlowLayout
{
    self = [super initWithCollectionViewLayout:[[CSStickyHeaderFlowLayout alloc] init]];
    if (self) {
        self.recordings = @[];
        self.headerNib = [UINib nibWithNibName:@"WILFeedHeader" bundle:nil];
        self.cellNib = [UINib nibWithNibName:@"WILCell" bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    // Locate your layout
    CSStickyHeaderFlowLayout *layout = (id)self.collectionViewLayout;
    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        layout.parallaxHeaderReferenceSize = CGSizeMake(320, 426);
        layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(320, 110);
        layout.parallaxHeaderAlwaysOnTop = YES;
        
        // If we want to disable the sticky header effect
        layout.disableStickyHeaders = YES;
    }
    
    layout.itemSize = CGSizeMake(320.0, 170.0);
    
    // Locate the nib and register it to your collection view
    
    [self.collectionView registerNib:self.headerNib
          forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
                 withReuseIdentifier:@"header"];
    
    // Register cell classes
    
    [self.collectionView registerNib:self.cellNib forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    self.playController = [[WILPlayViewController alloc] initWithNibName:nil bundle:nil];
    self.playController.view.frame = CGRectMake(0, 0, 320, 200);
    [self addChildViewController:self.playController];
    [self.view addSubview:self.playController.view];
    self.playController.view.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshRecordings];
}

- (void)updateRecordings:(NSArray*)recordings {
    NSSortDescriptor *sortDescriptor =
        [NSSortDescriptor wilsonRankSortDescriptorWithPositiveKey:@"upVotes"
                                                  negativeKey:@"downvotes"
                                                    ascending:NO];
    self.recordings = [recordings sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.collectionView reloadData];
}

- (void)refreshRecordings {
    [[WILRecordingManager sharedManager] list:^(NSArray *recordings, NSError *error) {
        if(error != nil) {
            NSLog(@"Error %@", error.localizedDescription);
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:error.localizedDescription delegate:nil cancelButtonTitle:@":(" otherButtonTitles:nil] show];
        } else {
            [self updateRecordings:recordings];
        }
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.recordings.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WILCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    PFObject *obj = self.recordings[indexPath.row];
    
    cell.object = obj;
    cell.delegate = self;
    
    if ( [cell.contentView viewWithTag:88] ) {
        /// remove player from cell. reuse.
        [self.playController stopPlaying];
        [self.playController.view removeFromSuperview];
    }

    return cell;
}

#pragma mark <UICollectionViewDelegate>


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        WILCell *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"sectionHeader"
                                                                 forIndexPath:indexPath];
        
        return cell;
        
    } else if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        WILFeedHeader *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"header"
                                                                                   forIndexPath:indexPath];
        
        cell.delegate = self;
        
        return cell;
    }
    return nil;
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	
}
*/

#pragma mark Collection view layout things
// Layout: Set cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize mElementSize = CGSizeMake(320, 170);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(20,0,0,0);  // top, left, bottom, right
}


#pragma mark Cell delegate methods

- (void)collectionViewControllerCellDidVoteDown:(WILCell*)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    PFObject *object = self.recordings[indexPath.row];
    [[WILRecordingManager sharedManager] vote:WILRecordingVoteDown forRecordingID:object.objectId completionHandler:^(BOOL succeeded, NSError *error) {
        if(error == nil && succeeded == YES) {
            object[@"downVotes"] = @([object[@"downVotes"] integerValue] + 1);
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else if(error) {
            
        } else {
            
        }
    }];
}

- (void)collectionViewControllerCellDidVoteUp:(WILCell*)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    PFObject *object = self.recordings[indexPath.row];
    [[WILRecordingManager sharedManager] vote:WILRecordingVoteUp forRecordingID:object.objectId completionHandler:^(BOOL succeeded, NSError *error) {
        if(error == nil && succeeded == YES) {
            object[@"upVotes"] = @([object[@"upVotes"] integerValue] + 1);
            WILCell *cell = (WILCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            cell.object = object;
        } else if(error) {
            
        } else {
            
        }
    }];
}

- (void)collectionViewControllerCellSaidPlay:(WILCell*)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    PFObject *object = self.recordings[indexPath.row];
    NSLog(@"Play! %@", object.objectId);
    
    [self.playController stopPlaying];
    [self.playController play:object];
    self.playController.view.tag = 88;
    self.playController.view.hidden = NO;
    
    [cell.contentView addSubview:self.playController.view];
    self.playController.view.frame = CGRectMake(0, 0, 320, 100);
}

# pragma mark Header delegate methods

- (void)openRecordUI {
    WILRecordViewController *vc = [[WILRecordViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:vc animated:YES completion:^{
        NSLog(@"Presented %@", vc);
    }];
}

- (void)openHelpUI {
    
}


@end
