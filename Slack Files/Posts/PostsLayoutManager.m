//
//  PostsLayoutManager.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/12/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "PostsLayoutManager.h"
#import "PostsProcessor.h"

@implementation PostsLayoutManager

- (void)drawBackgroundForCharacterRange:(NSRange)charactersToShow atPoint:(CGPoint)origin
{
    // Skip if there is no background to draw. This helps improving performance by not drawing unnecessarily.
    if (NO == [self hasDrawableBackground])
    {
        return;
    }
    
    NSRange r = [self glyphRangeForCharacterRange:charactersToShow actualCharacterRange:NULL];
    
    [self drawBackgroundForGlyphRange:r atPoint:origin];
}

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
    if (NSNotFound == glyphsToShow.location ||  glyphsToShow.length == 0)
    {
        return;
    }

    NSRange         characterRange = [self characterRangeForGlyphRange:glyphsToShow actualGlyphRange:NULL];
    NSMutableArray  *preSpans = [NSMutableArray array];
    NSMutableArray  *checkListSpans = [NSMutableArray array];

    //  PRE blocks have a frame drawn around them. These can get overdrawn by other background
    //  drawing operations. So we gather up all of the areas with these spans, and draw their
    //  decorations after regular background drawing is done.
    [self.textStorage enumerateAttribute:PostsPreAttributeName inRange:characterRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        
        //  If the attribute is not present then the block will be called once with a nil value.
        if (value)
        {
            [preSpans addObject:[NSValue valueWithRange:range]];
        }
    }];

    [self.textStorage enumerateAttribute:PostsChecklistAttributeName inRange:characterRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {

        //  If the attribute is not present then the block will be called once with a nil value.
        if (value)
        {
            [checkListSpans addObject:[NSValue valueWithRange:range]];
        }
    }];

    //  Do the default background drawing in all cases
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];

    //  Then add a frame around PRE blocks
    for (NSValue *preSpan in preSpans)
    {
        CGRect  frame = [self frameRectForCharacterRange:[preSpan rangeValue]];
        
        if (CGSizeEqualToSize(frame.size, CGSizeZero))
        {
            continue;
        }

        frame = CGRectOffset(frame, origin.x, origin.y);
        frame = CGRectInset(frame, 0, 2);
        
        NSBezierPath    *path = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:self.theme.preBorderRadius yRadius:self.theme.preBorderRadius];

        [self.theme.preBackgroundColor setFill];
        [self.theme.preBorderColor setStroke];
        
        path.lineWidth = self.theme.preBorderWidth;
        
        [path fill];
        [path stroke];
    }

    //  Then add a frame around PRE blocks
    for (NSValue *checkListSpan in checkListSpans)
    {
        CGRect  frame = [self frameRectForCharacterRange:[checkListSpan rangeValue]];

        if (CGSizeEqualToSize(frame.size, CGSizeZero))
        {
            continue;
        }

        frame = CGRectOffset(frame, origin.x, origin.y);
        frame = CGRectInset(frame, 0, 2);

        NSBezierPath    *path = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:self.theme.checklistBorderRadius yRadius:self.theme.checklistBorderRadius];

        [self.theme.checklistBackgroundColor setFill];
        [self.theme.checklistBorderColor setStroke];

        path.lineWidth = self.theme.checklistBorderWidth;

        [path fill];
        [path stroke];
    }
}

- (void)drawGlyphsForCharacterRange:(NSRange)charactersToShow atPoint:(CGPoint)origin
{
    NSRange r = [self glyphRangeForCharacterRange:charactersToShow actualCharacterRange:NULL];
    
    [self drawGlyphsForGlyphRange:r atPoint:origin];
}

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
    if (NSNotFound == glyphsToShow.location ||  glyphsToShow.length == 0) {
        return;
    }
    
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}

- (CGRect)frameRectForCharacterRange:(NSRange)characterRange
{
    NSRange         glyphRange = [self glyphRangeForCharacterRange:characterRange actualCharacterRange:NULL];
    __block CGRect  unionRect = CGRectZero;
    __block BOOL    firstRect = YES;

    [self enumerateLineFragmentsForGlyphRange:glyphRange usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop) {

        CGRect  r = rect;

        if (firstRect)
        {
            unionRect = r;
            firstRect = NO;
        }

        unionRect = CGRectUnion(unionRect, r);
    }];
    
    return unionRect;
}

- (BOOL)hasDrawableBackground
{
    static NSArray          *backgroundAttributeNames = nil;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^{

        backgroundAttributeNames = @[ NSBackgroundColorAttributeName, PostsPreAttributeName, PostsChecklistAttributeName ];
    });
    
    __block BOOL hasBackground = NO;
    
    [self.textStorage enumerateAttributesInRange:NSMakeRange(0, self.textStorage.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        
        for (NSString *attributeName in backgroundAttributeNames)
        {
            if (attrs[attributeName])
            {
                hasBackground = YES;
                *stop = YES;
            }
        }
    }];
    
    return hasBackground;
}

@end
