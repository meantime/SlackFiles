//
//  FileCollectionViewItemView.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/5/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "FileCollectionViewItemView.h"

#import "AppDelegate.h"

@implementation FileCollectionViewItemView

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];

    if ([theEvent clickCount] > 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:OpenFileWindowNotification object:self.file];
    }
}

@end
