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
    self.sortedFiles = [self.baseFiles sortedResultsUsingProperty:@"timestamp" ascending:NO];

    [self.collectionView reloadData];
//    [self subscribeToCollectionNotifications];
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
        NSIndexPath *path = [NSIndexPath indexPathForItem:[changedRow integerValue] inSection:0];

        [result addObject:path];
    }

    return [NSSet<NSIndexPath *> setWithSet:result];
}

#pragma mark - NSResponder Actions

- (BOOL)resignFirstResponder
{
    return NO;
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (void)scrollPageDown:(id)sender
{
    NSInteger   highestIndex = -1;
    NSSet       *indexPaths = self.collectionView.indexPathsForVisibleItems;
    NSRect      visibleRect = self.collectionView.visibleRect;

    for (NSIndexPath *path in indexPaths)
    {
        NSCollectionViewItem    *item = [self.collectionView itemAtIndexPath:path];

        if (NSContainsRect(visibleRect, item.view.frame))
        {
            highestIndex = MAX(highestIndex, path.item);
        }
    }

    NSInteger   nextIndex = highestIndex + 1;

    if (nextIndex < self.sortedFiles.count)
    {
        NSIndexPath *path = [NSIndexPath indexPathForItem:nextIndex inSection:0];
        NSSet       *item = [NSSet setWithObject:path];

        [self.collectionView.animator scrollToItemsAtIndexPaths:item scrollPosition:NSCollectionViewScrollPositionTop];
    }
}

- (void)scrollPageUp:(id)sender
{
    NSInteger   lowestIndex = NSNotFound;
    NSSet       *indexPaths = self.collectionView.indexPathsForVisibleItems;
    NSRect      visibleRect = self.collectionView.visibleRect;

    for (NSIndexPath *path in indexPaths)
    {
        NSCollectionViewItem    *item = [self.collectionView itemAtIndexPath:path];

        if (NSContainsRect(visibleRect, item.view.frame))
        {
            lowestIndex = MIN(lowestIndex, path.item);
        }
    }

    NSInteger   nextIndex = lowestIndex - 1;

    if ((nextIndex < self.sortedFiles.count) && (nextIndex >= 0))
    {
        NSIndexPath *path = [NSIndexPath indexPathForItem:nextIndex inSection:0];
        NSSet       *item = [NSSet setWithObject:path];

        [self.collectionView.animator scrollToItemsAtIndexPaths:item scrollPosition:NSCollectionViewScrollPositionBottom];
    }
}

- (void)scrollToBeginningOfDocument:(id)sender
{
    if (0 == self.sortedFiles.count)
    {
        return;
    }

    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
    NSSet       *item = [NSSet setWithObject:path];

    [self.collectionView scrollToItemsAtIndexPaths:item scrollPosition:NSCollectionViewScrollPositionTop];
}

- (void)scrollToEndOfDocument:(id)sender
{
    if (0 == self.sortedFiles.count)
    {
        return;
    }

    NSIndexPath *path = [NSIndexPath indexPathForItem:(self.sortedFiles.count - 1) inSection:0];
    NSSet       *item = [NSSet setWithObject:path];

    [self.collectionView scrollToItemsAtIndexPaths:item scrollPosition:NSCollectionViewScrollPositionBottom];
}

- (void)insertNewline:(id)sender
{
    NSSet   *selection = [self.collectionView selectionIndexPaths];

    if (selection.count)
    {
        NSCollectionViewItem    *item = [self.collectionView itemAtIndexPath:[selection anyObject]];

        [[NSNotificationCenter defaultCenter] postNotificationName:OpenFileWindowNotification object:item.representedObject];
    }
}

- (void)selectAll:(id)sender
{
    //  Since there are potentially thousands of items that could be selected this would just
    //  be horrible. Do not ever do anything here.
}

- (void)doCommandBySelector:(SEL)aSelector
{
    if (NO == [self respondsToSelector:aSelector])
    {
        NSLog(@"FilesCollectionViewController was asked to: %@", NSStringFromSelector(aSelector));
        return;
    }
    
    [super doCommandBySelector:aSelector];
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
    NSCollectionViewItem    *item = [self.collectionView makeItemWithIdentifier:@"FilesCollectionViewItem" forIndexPath:indexPath];

    item.representedObject = self.sortedFiles[indexPath.item];

    return item;
}

#pragma mark - <SyncUIDelegate>

- (void)didFetchMoreFiles
{
    [self loadFilesData];
}

#pragma mark - <ChannelFilterDelegate>

- (void)clearFilter
{
    NSLog(@"clear filter");
}

- (void)filterWithChannel:(Channel *)channel
{
    NSLog(@"channel filter %@", channel);
}

- (void)filterWithGroup:(Group *)group
{
    NSLog(@"group filter %@", group);
}

- (void)filterWithIM:(IM *)im
{
    NSLog(@"im filter %@", im);
}

- (void)filterWithUser:(User *)user
{
    NSLog(@"user filter %@", user);
}

@end
