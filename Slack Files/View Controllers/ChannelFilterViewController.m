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

@property               Team                *team;
@property               enum FilterType     filterType;
@property               NSString            *nameProperty;
@property               RLMResults          *channelList;

@end

@implementation ChannelFilterViewController

+ (instancetype)viewControllerForTeam:(Team *)team
{
    ChannelFilterViewController *result = [[ChannelFilterViewController alloc] initWithNibName:@"ChannelFilterViewController" bundle:nil];

    result.team = team;

    return result;

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

    RLMResults  *unsortedList;

    switch (self.filterType)
    {
        case FilterTypeUser:
            self.nameProperty = @"username";
            unsortedList = [User objectsWhere:@"team = %@", self.team];
            break;

        case FilterTypeChannel:
            self.nameProperty = @"name";
            unsortedList = [Channel objectsWhere:@"team = %@", self.team];
            break;

        case FilterTypeGroup:
            self.nameProperty = @"name";
            unsortedList = [Group objectsWhere:@"team = %@", self.team];
            break;

        case FilterTypeIM:
            self.nameProperty = @"name";
            unsortedList = [IM objectsWhere:@"team = %@", self.team];
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

#pragma mark - <NSTableViewDelegate>

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *view = [tableView makeViewWithIdentifier:@"FilterListRow" owner:nil];
    RLMObject       *modelObject = self.channelList[row];

    view.textField.stringValue = modelObject[self.nameProperty];

    return view;
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
