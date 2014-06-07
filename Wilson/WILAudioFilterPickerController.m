//
//  WILAudioFilterPickerController.m
//  Wilson
//
//  Created by Sean Conrad on 6/7/14.
//  Copyright (c) 2014 Team Wilson. All rights reserved.
//

#import "WILAudioFilterPickerController.h"
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
        self.selectedFilter = WILAudioFilterNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kAudioFilterPickerCellIdentifier];
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
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kAudioFilterPickerCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:cell.bounds];
    [cell addSubview:testLabel];
    
    testLabel.text = [[self.filters objectAtIndex:indexPath.row] description];
    testLabel.textColor = [UIColor whiteColor];
    testLabel.textAlignment = NSTextAlignmentCenter;
    
    testLabel.font = [UIFont boldSystemFontOfSize:20];
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedFilter = [[self.filters objectAtIndex:indexPath.row] integerValue];
    
}

@end
