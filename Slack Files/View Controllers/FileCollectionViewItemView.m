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

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];

    if (self)
    {
        highlightState = NSCollectionViewItemHighlightNone;
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];

    if (self)
    {
        highlightState = NSCollectionViewItemHighlightNone;

        self.wantsLayer = YES;
        self.layer.cornerRadius = 8.0;
    }

    return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if ([theEvent clickCount] == 2)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:OpenFileWindowNotification object:self.file];
    }
    else
    {
        [super mouseDown:theEvent];
    }
}

- (NSCollectionViewItemHighlightState)highlightState
{
    return highlightState;
}

- (void)setHighlightState:(NSCollectionViewItemHighlightState)newHighlightState
{
    if (highlightState != newHighlightState)
    {
        highlightState = newHighlightState;

        // Cause our -updateLayer method to be invoked, so we can update our appearance to reflect the new state.
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)isSelected
{
    return selected;
}

- (void)setSelected:(BOOL)flag
{
    if (selected != flag)
    {
        selected = flag;

        // Cause our -updateLayer method to be invoked, so we can update our appearance to reflect the new state.
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)wantsUpdateLayer
{
    return YES;
}

- (void)updateLayer
{
    self.layer.borderColor = [self borderColor].CGColor;
    self.layer.backgroundColor = [self backgroundColor].CGColor;
    self.layer.borderWidth = [self borderWidth];
}

- (NSColor *)borderColor
{
    NSColor *color;

    if (selected)
    {
        if (NSCollectionViewItemHighlightForDeselection == highlightState)
        {
            color = [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.5];
        }
        else
        {
            color = [NSColor redColor];
        }
    }
    else
    {
        if (NSCollectionViewItemHighlightForSelection == highlightState)
        {
            color = [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.5];
        }
        else
        {
            color = [NSColor lightGrayColor];
        }
    }

    return color;
}

- (NSColor *)backgroundColor
{
    NSColor *color;

    if (selected)
    {
        if (NSCollectionViewItemHighlightForDeselection == highlightState)
        {
            color = [NSColor colorWithCalibratedWhite:0.95 alpha:0.5];
        }
        else
        {
            color = [NSColor colorWithCalibratedWhite:0.95 alpha:1.0];
        }
    }
    else
    {
        if (NSCollectionViewItemHighlightForSelection == highlightState)
        {
            color = [NSColor colorWithCalibratedWhite:0.95 alpha:0.5];
        }
        else
        {
            color = [NSColor whiteColor];
        }
    }

    return color;
}

- (CGFloat)borderWidth
{
    CGFloat width;

    if (selected)
    {
        if (NSCollectionViewItemHighlightForDeselection == highlightState)
        {
            width = 1.5;
        }
        else
        {
            width = 2.0;
        }
    }
    else
    {
        if (NSCollectionViewItemHighlightForSelection == highlightState)
        {
            width = 1.5;
        }
        else
        {
            width = 1.0;
        }
    }

    return width;
}

@end
