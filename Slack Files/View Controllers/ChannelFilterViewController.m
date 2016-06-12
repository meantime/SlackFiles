//
//  ChannelFilterViewController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "ChannelFilterViewController.h"

#import "Channel.h"
#import "Group.h"
#import "IM.h"
#import "Team.h"
#import "User.h"

NS_ENUM(NSUInteger, FilterType)
{
    FilterTypeUser,
    FilterTypeChannel,
    FilterTypeGroup,
    FilterTypeIM
};

@interface ChannelFilterViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property   IBOutlet    NSTableView         *tableView;
@property   IBOutlet    NSSegmentedControl  *filterSelector;
@property   IBOutlet    NSButton            *includeArchivedDeleted;

@property               Team                *team;
@property               enum FilterType     filterType;
@property               NSString            *nameProperty;
@property               NSString            *deletedProperty;
@property               BOOL                useFullName;

@property               RLMResults          *channelList;

@end

@implementation ChannelFilterViewController

+ (instancetype)viewControllerForTeam:(Team *)team
{
    ChannelFilterViewController *result = [[ChannelFilterViewController alloc] initWithNibName:@"ChannelFilterViewController" bundle:nil];

    result.team = team;

    return result;

}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.filterType = FilterTypeUser;

    [self resetFilter];
}

- (void)resetFilter
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;

    self.filterSelector.integerValue = self.filterType;

    BOOL        includeDeleted = self.includeArchivedDeleted.integerValue;
    RLMResults  *unsortedList;

    switch (self.filterType)
    {
        case FilterTypeUser:
            self.nameProperty = self.useFullName ? @"realName" : @"username";
            self.deletedProperty = @"deleted";

            if (includeDeleted)
            {
                unsortedList = [User objectsWhere:@"team = %@", self.team];
            }
            else
            {
                unsortedList = [User objectsWhere:@"team = %@ AND deleted = false", self.team];
            }
            break;

        case FilterTypeChannel:
            self.nameProperty = @"name";
            self.deletedProperty = @"archived";

            if (includeDeleted)
            {
                unsortedList = [Channel objectsWhere:@"team = %@", self.team];
            }
            else
            {
                unsortedList = [Channel objectsWhere:@"team = %@ AND archived = false", self.team];
            }

            break;

        case FilterTypeGroup:
            self.nameProperty = @"name";
            self.deletedProperty = @"archived";

            if (includeDeleted)
            {
                unsortedList = [Group objectsWhere:@"team = %@", self.team];
            }
            else
            {
                unsortedList = [Group objectsWhere:@"team = %@ AND archived = false", self.team];
            }

            break;

        case FilterTypeIM:
            self.nameProperty = @"name";
            self.deletedProperty = @"deleted";

            if (includeDeleted)
            {
                unsortedList = [IM objectsWhere:@"team = %@", self.team];
            }
            else
            {
                unsortedList = [IM objectsWhere:@"team = %@ AND deleted = false", self.team];
            }

            break;
    }

    self.channelList = [unsortedList sortedResultsUsingProperty:self.nameProperty ascending:YES];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView reloadData];
}

- (IBAction)changeFilter:(NSSegmentedControl *)selector
{
    self.filterType = selector.integerValue;

    [self resetFilter];
}

- (IBAction)toggleArchiveDeleted:(id)sender
{
    [self resetFilter];
}

- (IBAction)toggleFullName:(id)sender
{
    self.useFullName = self.useFullName ^ 1;

    if ((FilterTypeUser == self.filterType) || (FilterTypeIM == self.filterType))
    {
        NSRange     visibleRows = [self.tableView rowsInRect:self.tableView.frame];
        NSIndexSet  *rows = [NSIndexSet indexSetWithIndexesInRange:visibleRows];
        NSIndexSet  *columns = [NSIndexSet indexSetWithIndex:0];

        if (FilterTypeUser == self.filterType)
        {
            self.nameProperty = self.useFullName ? @"realName" : @"username";
        }
        else if (FilterTypeIM == self.filterType)
        {
            self.nameProperty = self.useFullName ? @"realName" : @"name";
        }

        [self.tableView reloadDataForRowIndexes:rows columnIndexes:columns];
    }
}

#pragma mark - <NSTableViewDelegate>

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *view = [tableView makeViewWithIdentifier:@"FilterListRow" owner:nil];
    RLMObject       *modelObject = self.channelList[row];
    NSNumber        *deleted = modelObject[self.deletedProperty];
    NSMutableAttributedString   *title = [[NSMutableAttributedString alloc] initWithString:modelObject[self.nameProperty]];

    if ([deleted boolValue])
    {
        [title addAttribute:NSStrikethroughStyleAttributeName
                      value:deleted
                      range:NSMakeRange(0, title.length)];
    }

    view.textField.attributedStringValue = title;

    return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSLog(@"selected row indexes %@", self.tableView.selectedRowIndexes);
    NSLog(@"selected row %ld", self.tableView.selectedRow);
}

#pragma mark - <NSTableViewDataSource>

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.channelList.count;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    return self.channelList[row];
}

@end
