//
//  FileCollectionViewItemView.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/5/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class File;

@interface FileCollectionViewItemView : NSView
{
    NSCollectionViewItemHighlightState highlightState;
    BOOL    selected;
}

@property   File                    *file;
@property (getter=isSelected) BOOL  selected;
@property NSCollectionViewItemHighlightState highlightState;

@end
