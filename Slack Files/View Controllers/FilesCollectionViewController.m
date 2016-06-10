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

@property               IBOutlet    NSCollectionView        *collectionView;

@property                           Team                    *team;
@property (nullable)                RLMResults              *baseFiles;
@property (nullable)                RLMResults              *sortedFiles;
@property (nullable)                RLMNotificationToken    *filesNotificationToken;

@end

@implementation FilesCollectionViewController

+ (instancetype)viewControllerForTeam:(Team *)team
{
    FilesCollectionViewController   *result = [[FilesCollectionViewController alloc] initWithNibName:@"FilesCollectionViewController" bundle:nil];

    result.team = team;

    return result;
}

- (void)dealloc
{
    [self.filesNotificationToken stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.wantsLayer = YES;

    [self.collectionView registerClass:[FilesCollectionViewItem class] forItemWithIdentifier:@"FilesCollectionViewItem"];
}

- (void)loadFilesData
{
    self.baseFiles = [File objectsWhere:@"team = %@", self.team];
    self.sortedFiles = [self.baseFiles sortedResultsUsingProperty:@"creationDate" ascending:NO];

    [self subscribeToCollectionNotifications];
}

- (void)subscribeToCollectionNotifications
{
    [self.filesNotificationToken stop];

    __weak typeof(self) weakSelf = self;

    self.filesNotificationToken = [self.sortedFiles addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable changes, NSError * _Nullable error) {

        if (error)
        {
            NSLog(@"%@", error);
            return;
        }

        NSCollectionView    *collectionView = weakSelf.collectionView;

        if (nil == collectionView)
        {
            return;
        }

        if (nil == changes)
        {
            [collectionView reloadData];
            return;
        }

        NSSet   *changedIndices;

        changedIndices = [weakSelf setOfIndexPathsForChangesInArray:[changes deletions]];
        [collectionView deleteItemsAtIndexPaths:changedIndices];

        changedIndices = [weakSelf setOfIndexPathsForChangesInArray:[changes insertions]];
        [collectionView insertItemsAtIndexPaths:changedIndices];

        [weakSelf setOfIndexPathsForChangesInArray:[changes modifications]];
        [collectionView reloadItemsAtIndexPaths:changedIndices];
    }];
}

- (nonnull NSSet<NSIndexPath *> *)setOfIndexPathsForChangesInArray:(nullable NSArray<NSNumber *> *)changedRows
{
    NSMutableSet    *result = [NSMutableSet set];

    for (NSNumber *changedRow in changedRows)
    {
        NSIndexPath *path = [NSIndexPath indexPathWithIndex:[changedRow integerValue]];

        [result addObject:path];
    }

    return [NSSet<NSIndexPath *> setWithSet:result];
}

#pragma mark - <NSCollectionViewDelegate>

- (void)collectionView:(NSCollectionView *)collectionView willDisplayItem:(NSCollectionViewItem *)item forRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    File                    *file = self.sortedFiles[indexPath.item];
    FilesCollectionViewItem *viewItem = (FilesCollectionViewItem *) item;

    [viewItem configureWithFile:file];
}

- (void)collectionView:(NSCollectionView *)collectionView didEndDisplayingItem:(NSCollectionViewItem *)item forRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    FilesCollectionViewItem *viewItem = (FilesCollectionViewItem *) item;

    [viewItem prepareForReuse];
}

#pragma mark - <NSCollectionViewDataSource>

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sortedFiles.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.collectionView makeItemWithIdentifier:@"FilesCollectionViewItem" forIndexPath:indexPath];
}

#pragma mark - <SyncUIDelegate>

- (void)didFetchMoreFiles
{
    [self loadFilesData];
}

@end
