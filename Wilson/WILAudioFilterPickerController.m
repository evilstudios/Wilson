//
//  WILAudioFilterPickerController.m
//  Wilson
//
//  Created by Sean Conrad on 6/7/14.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import "WILAudioFilterPickerController.h"
#import "WILAudioFilterPickerCell.h"

#import <DEAudioUnitFilter.h>

////////////////////////////////////////////////////////////////////////////////

NSString *const kAudioFilterPickerCellIdentifier = @"kAudioFilterPickerCellIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface WILAudioFilterPickerController ()
@end

////////////////////////////////////////////////////////////////////////////////

@implementation WILAudioFilterPickerController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self.collectionView registerClass:[WILAudioFilterPickerCell class] forCellWithReuseIdentifier:kAudioFilterPickerCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    
    // DEFAULT LAYOUT
    // contents are square, slightly smaller than the preferred height of the collection view
    
    CGFloat preferredHeight = [WILAudioFilterPickerController preferredHeight];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGFloat preferredPadding = 1;
    flowLayout.sectionInset = UIEdgeInsetsMake(preferredPadding, preferredPadding, preferredPadding, preferredPadding);
    flowLayout.minimumInteritemSpacing = preferredPadding;
    flowLayout.minimumLineSpacing = preferredPadding;
    
    CGFloat preferredSize = preferredHeight - 2 * preferredPadding;
    flowLayout.itemSize = CGSizeMake(preferredSize, preferredSize);
    
    return flowLayout;
}

+ (CGFloat)preferredHeight {
    return 100;
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WILAudioFilterPickerCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kAudioFilterPickerCellIdentifier forIndexPath:indexPath];
    
    cell.filterLabel.text = [[self.filters objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    NSDictionary *cellFilter = [self.filters objectAtIndex:indexPath.row];
    cell.filterSelected = (cellFilter == self.selectedFilter);
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WILAudioFilterPickerCell *cell = (WILAudioFilterPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    for (WILAudioFilterPickerCell *visibleCell in collectionView.visibleCells) {
        visibleCell.filterSelected = (visibleCell == cell) ? !visibleCell.filterSelected : NO;
    }
    
    self.selectedFilter = [self.filters objectAtIndex:indexPath.row];
    
}

@end
