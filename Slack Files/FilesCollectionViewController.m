//
//  FilesCollectionViewController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/5/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "FilesCollectionViewController.h"

@import Realm;

#import "File.h"
#import "FilesCollectionViewItem.h"

@interface FilesCollectionViewController () <NSCollectionViewDelegate, NSCollectionViewDataSource>

@property               IBOutlet    NSCollectionView    *collectionView;

@property                           Team                *team;
@property (nullable)                RLMResults          *files;

@end

@implementation FilesCollectionViewController

+ (instancetype)viewControllerForTeam:(Team *)team
{
    FilesCollectionViewController   *result = [[FilesCollectionViewController alloc] initWithNibName:@"FilesCollectionViewController" bundle:nil];

    result.team = team;

    return result;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    NSCollectionViewFlowLayout  *layout = [NSCollectionViewFlowLayout new];
//
//    layout.estimatedItemSize = CGSizeMake(165, 215);
//    layout.minimumInteritemSpacing = 10.0;
//    layout.minimumLineSpacing = 10.0;
//    
//    self.collectionView.collectionViewLayout = layout;
    self.view.wantsLayer = YES;

    [self.collectionView registerClass:[FilesCollectionViewItem class] forItemWithIdentifier:@"FilesCollectionViewItem"];

    self.files = [File objectsWhere:@"team = %@", self.team];

    [self.collectionView reloadData];
}

#pragma mark - <NSCollectionViewDelegate>

#pragma mark - <NSCollectionViewDataSource>

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.files.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    FilesCollectionViewItem *item = [self.collectionView makeItemWithIdentifier:@"FilesCollectionViewItem" forIndexPath:indexPath];
    File                    *file = self.files[indexPath.item];

    [item configureWithFile:file];

    return item;
}

@end
