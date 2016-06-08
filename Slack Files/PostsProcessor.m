//
//  PostsProcessor.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/7/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "PostsProcessor.h"

static CGFloat  kDefaultFontSize        = 18.0;
static CGFloat  kDefaultBorderWidth     = 1.0;
static CGFloat  kDefaultBorderRadius    = 5.0;
static CGFloat  kDefaultBulletIndent    = 5.0;

@interface PostsProcessor ()

@property (nonnull)     PostsTheme  *baseTheme;
@property (nullable)    PostsTheme  *computedTheme;

@property (nullable)    NSFont      *currentBaseFont;
@property (nullable)    NSFont      *currentBoldFont;
@property (nullable)    NSFont      *currentItalicFont;
@property (nullable)    NSFont      *currentBoldItalicFont;
@property (nullable)    NSColor     *currentTextColor;

@property               NSUInteger  nextOLNumber;

@end

@implementation PostsProcessor

+ (nonnull PostsTheme *)defaultTheme
{
    return [PostsTheme new];
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.baseTheme = [PostsProcessor defaultTheme];
        self.nextOLNumber = 1;
    }

    return self;
}

- (nonnull NSAttributedString *)attributedStringFromPost:(nonnull NSDictionary *)document
{
    [self computeTheme];

    NSAttributedString          *lineBreak = [[NSAttributedString alloc] initWithString:@"\n"
                                                                             attributes:@{ NSFontAttributeName : self.computedTheme.baseFont } ];
    NSMutableAttributedString   *result = [NSMutableAttributedString new];
    NSDictionary                *root = document[@"root"];
    NSArray                     *paragraphs = root[@"children"];
    NSString                    *lastType = nil;
    NSUInteger                  paragraphCount = 0;
    NSUInteger const            maxParagraphs = 100;

    for (NSDictionary *paragraph in paragraphs)
    {
        if (paragraphCount == maxParagraphs)
        {
            break;
        }

        NSString            *type = paragraph[@"type"];
        NSAttributedString  *formattedText = [self processParagraph:paragraph];

        NSLog(@"%@", formattedText);

        [result appendAttributedString:formattedText];
        [result appendAttributedString:lineBreak];

        if (NO == [type isEqualToString:lastType])
        {
            self.nextOLNumber = 1;
        }

        lastType = type;
        paragraphCount++;

        if ([@"ol" isEqualToString:lastType])
        {
            self.nextOLNumber = self.nextOLNumber + 1;
        }
    }

    return [[NSAttributedString alloc] initWithAttributedString:result];
}

- (nonnull NSAttributedString *)processParagraph:(nonnull NSDictionary *)paragraph
{
    NSString    *type = paragraph[@"type"];
    NSString    *text = paragraph[@"text"];
    NSMutableAttributedString   *result = [NSMutableAttributedString new];

    if ([@"p" isEqualToString:type])
    {
        NSLog(@"p");
        return [self processBodyText:paragraph];
    }
    else if ([@"h1" isEqualToString:type])
    {
        NSLog(@"h1");
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:text]];
        [result addAttributes:@{ NSFontAttributeName : self.computedTheme.h1Font } range:NSMakeRange(0, text.length)];
    }
    else if ([@"h2" isEqualToString:type])
    {
        NSLog(@"h2");
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:text]];
        [result addAttributes:@{ NSFontAttributeName : self.computedTheme.h2Font } range:NSMakeRange(0, text.length)];
    }
    else if ([@"h3" isEqualToString:type])
    {
        NSLog(@"h3");
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:text]];
        [result addAttributes:@{ NSFontAttributeName : self.computedTheme.h3Font } range:NSMakeRange(0, text.length)];
    }
    else if ([@"ol" isEqualToString:type])
    {
        NSLog(@"ol");
        return [self processOLText:paragraph];
    }
    else if ([@"ul" isEqualToString:type])
    {
        NSLog(@"ul");
        return [self processULText:paragraph];
    }
    else if ([@"cl" isEqualToString:type])
    {
        NSLog(@"cl");
        return [self processCLText:paragraph];
    }
    else if ([@"pre" isEqualToString:type])
    {
        NSLog(@"pre");
        return [self processPreText:paragraph];
    }
    else
    {
        NSLog(@"%@", type);
        NSString    *error = [NSString stringWithFormat:@"Unhandled paragraph type '%@'", type];

        result = [[NSMutableAttributedString alloc] initWithString:error
                                                        attributes:@{ NSForegroundColorAttributeName : [NSColor redColor],
                                                                      NSFontAttributeName            : self.computedTheme.baseFont } ];
    }

    return result;
}

- (nonnull NSAttributedString *)processBodyText:(nonnull NSDictionary *)paragraph
{
    NSString                    *text = paragraph[@"text"];
    NSMutableAttributedString   *result = [[NSMutableAttributedString alloc] initWithString:text];

    self.currentBaseFont = self.computedTheme.baseFont;
    self.currentBoldFont = self.computedTheme.boldFont;
    self.currentItalicFont = self.computedTheme.italicFont;
    self.currentBoldItalicFont = self.computedTheme.boldItalicFont;
    self.currentTextColor = self.computedTheme.textColor;

    [self applyCharacterStyling:paragraph[@"formats"] toAttributedString:result];

    return result;
}

- (nonnull NSAttributedString *)processPreText:(nonnull NSDictionary *)paragraph
{
    NSString                    *text = paragraph[@"text"];
    NSMutableAttributedString   *result = [[NSMutableAttributedString alloc] initWithString:text];

    self.currentBaseFont = self.computedTheme.monospaceFont;
    self.currentBoldFont = self.computedTheme.monospaceFont;
    self.currentItalicFont = self.computedTheme.monospaceFont;
    self.currentBoldItalicFont = self.computedTheme.monospaceFont;
    self.currentTextColor = self.computedTheme.preTextColor;

    [self applyCharacterStyling:paragraph[@"formats"] toAttributedString:result];

    return result;
}

- (nonnull NSAttributedString *)processOLText:(nonnull NSDictionary *)paragraph
{
    NSString                    *text = paragraph[@"text"];
    NSMutableAttributedString   *formattedText = [[NSMutableAttributedString alloc] initWithString:text];

    self.currentBaseFont = self.computedTheme.baseFont;
    self.currentBoldFont = self.computedTheme.baseFont;
    self.currentItalicFont = self.computedTheme.baseFont;
    self.currentBoldItalicFont = self.computedTheme.baseFont;
    self.currentTextColor = self.computedTheme.textColor;

    [self applyCharacterStyling:paragraph[@"formats"] toAttributedString:formattedText];

    NSString                    *number = [NSString stringWithFormat:@"%ld. ", self.nextOLNumber];
    NSMutableAttributedString   *result = [[NSMutableAttributedString alloc] initWithString:number
                                                                                 attributes:@{ NSFontAttributeName : self.currentBaseFont }];

    [result appendAttributedString:formattedText];

    return result;
}

- (nonnull NSAttributedString *)processULText:(nonnull NSDictionary *)paragraph
{
    NSString                    *text = paragraph[@"text"];
    NSMutableAttributedString   *formattedText = [[NSMutableAttributedString alloc] initWithString:text];

    self.currentBaseFont = self.computedTheme.baseFont;
    self.currentBoldFont = self.computedTheme.baseFont;
    self.currentItalicFont = self.computedTheme.baseFont;
    self.currentBoldItalicFont = self.computedTheme.baseFont;
    self.currentTextColor = self.computedTheme.textColor;

    [self applyCharacterStyling:paragraph[@"formats"] toAttributedString:formattedText];

    NSString                    *bullet = [NSString stringWithFormat:@"%C ", self.computedTheme.listBullet];
    NSMutableAttributedString   *result = [[NSMutableAttributedString alloc] initWithString:bullet
                                                                                 attributes:@{ NSFontAttributeName : self.currentBaseFont }];

    [result appendAttributedString:formattedText];

    return result;
}

- (nonnull NSAttributedString *)processCLText:(nonnull NSDictionary *)paragraph
{
    NSString                    *text = paragraph[@"text"];
    NSMutableAttributedString   *formattedText = [[NSMutableAttributedString alloc] initWithString:text];
    BOOL                        isChecked = [paragraph[@"checked"] boolValue];
    unichar                     mark;

    if (isChecked)
    {
        mark = self.computedTheme.checklistCheckedMark;

        self.currentBaseFont = self.computedTheme.checklistCheckedFont;
        self.currentTextColor = self.computedTheme.checklistCheckedTextColor;
    }
    else
    {
        mark = self.computedTheme.checklistUncheckedMark;

        self.currentBaseFont = self.computedTheme.checklistUncheckedFont;
        self.currentTextColor = self.computedTheme.checklistUncheckedTextColor;
    }

    self.currentBoldFont = self.computedTheme.baseFont;
    self.currentItalicFont = self.computedTheme.baseFont;
    self.currentBoldItalicFont = self.computedTheme.baseFont;

    [self applyCharacterStyling:paragraph[@"formats"] toAttributedString:formattedText];

    NSString                    *markString = [NSString stringWithFormat:@"%C ", mark];
    NSMutableAttributedString   *result = [[NSMutableAttributedString alloc] initWithString:markString
                                                                                 attributes:@{ NSFontAttributeName              : self.currentBaseFont,
                                                                                               NSForegroundColorAttributeName   : self.currentTextColor }];

    [result appendAttributedString:formattedText];

    return result;
}

- (void)applyCharacterStyling:(nullable NSDictionary *)formats toAttributedString:(nonnull NSMutableAttributedString *)text
{
    if (0 == text.length)
    {
        [text appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" "]];
    }

    [text addAttributes:@{ NSFontAttributeName : self.currentBaseFont } range:NSMakeRange(0, text.length)];
    [text addAttributes:@{ NSForegroundColorAttributeName : self.currentTextColor } range:NSMakeRange(0, text.length)];

    if (0 == formats.count)
    {
        return;
    }

    NSMutableIndexSet   *allBolds = [NSMutableIndexSet new];
    NSMutableIndexSet   *allItalics = [NSMutableIndexSet new];
    NSMutableIndexSet   *allBoldsOrItalics = [NSMutableIndexSet new];
    NSMutableIndexSet   *underlines = [NSMutableIndexSet new];
    NSMutableIndexSet   *strikeThroughs = [NSMutableIndexSet new];
    NSMutableIndexSet   *codes = [NSMutableIndexSet new];

    for (NSString *format in formats.allKeys)
    {
        NSArray *spans = formats[format];

        if ([@"b" isEqualToString:format])
        {
            [self addSpans:spans toIndexSet:allBolds];
        }
        else if ([@"i" isEqualToString:format])
        {
            [self addSpans:spans toIndexSet:allItalics];
        }
        else if ([@"u" isEqualToString:format])
        {
            [self addSpans:spans toIndexSet:underlines];
        }
        else if ([@"strike" isEqualToString:format])
        {
            [self addSpans:spans toIndexSet:strikeThroughs];
        }
        else if ([@"code" isEqualToString:format])
        {
            [self addSpans:spans toIndexSet:codes];
        }
    }

    //  Take the bolds, and italics, XOR them to find the bold-italics, then AND against that
    //  to find the just-bolds and just-italics.
    [allBoldsOrItalics addIndexes:allBolds];
    [allBoldsOrItalics addIndexes:allItalics];

    NSMutableIndexSet   *justBolds = [allBoldsOrItalics mutableCopy];

    //  Remove the italics which will leave us with all the places that are just bolds
    [justBolds removeIndexes:allItalics];

    NSMutableIndexSet   *justItalics = [allBoldsOrItalics mutableCopy];

    //  Remove the italics which will leave us with all the places that are just bolds
    [justItalics removeIndexes:allBolds];

    NSMutableIndexSet   *justBoldItalics = allBoldsOrItalics;

    //  Remove the just bolds, and the just italics, from the union of the two which will leave
    //  us with the just bold-italics
    [justBoldItalics removeIndexes:justBolds];
    [justBoldItalics removeIndexes:justItalics];

    [justBolds enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {

        [text addAttributes:@{ NSFontAttributeName : self.currentBoldFont } range:range];
    }];

    [justItalics enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {

        [text addAttributes:@{ NSFontAttributeName : self.currentItalicFont } range:range];
    }];

    [justBoldItalics enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {

        [text addAttributes:@{ NSFontAttributeName : self.currentBoldItalicFont } range:range];
    }];

    [underlines enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {

        [text addAttributes:@{ NSUnderlineStyleAttributeName : @(1) } range:range];
    }];

    [strikeThroughs enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {

        [text addAttributes:@{ NSStrikethroughStyleAttributeName : @(1.5) } range:range];
    }];

    [codes enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {

        [text addAttributes:@{ NSFontAttributeName : self.computedTheme.monospaceFont } range:range];
        [text addAttributes:@{ NSForegroundColorAttributeName : self.computedTheme.codeTextColor } range:range];
        [text addAttributes:@{ NSBackgroundColorAttributeName : self.computedTheme.codeBackgroundColor } range:range];
    }];
}

- (void)addSpans:(nonnull NSArray *)spans toIndexSet:(nonnull NSMutableIndexSet *)indexSet
{
    NSUInteger const    N = spans.count;

    for (NSUInteger i = 0; i < N; i += 2)
    {
        NSUInteger  from    = [spans[i + 0] unsignedIntegerValue];
        NSUInteger  to      = [spans[i + 1] unsignedIntegerValue];

        [indexSet addIndexesInRange:NSMakeRange(from, to - from)];
    }
}

- (void)computeTheme
{
    self.computedTheme = self.baseTheme;
}

@end

@implementation PostsTheme

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.textColor                  = [NSColor blackColor];
        self.backgroundColor            = [NSColor whiteColor];

        self.h1Alignment                = NSTextAlignmentLeft;
        self.h2Alignment                = NSTextAlignmentLeft;
        self.h3Alignment                = NSTextAlignmentLeft;
        self.h1Font                     = [NSFont boldSystemFontOfSize:kDefaultFontSize];
        self.h2Font                     = [NSFont boldSystemFontOfSize:kDefaultFontSize];
        self.h3Font                     = [NSFont boldSystemFontOfSize:kDefaultFontSize];

        self.paragraphAlignment         = NSTextAlignmentJustified;
        self.baseFont                   = [NSFont systemFontOfSize:kDefaultFontSize];
        self.boldFont                   = [NSFont boldSystemFontOfSize:kDefaultFontSize];
        self.italicFont                 = self.baseFont;
        self.boldItalicFont             = self.baseFont;

        self.monospaceFont              = [NSFont userFixedPitchFontOfSize:kDefaultFontSize];
        self.monospaceBoldFont          = self.monospaceFont;
        self.monospaceItalicFont        = self.monospaceFont;
        self.monospaceBoldItalicFont    = self.monospaceFont;

        self.codeTextColor              = [NSColor blackColor];
        self.codeBackgroundColor        = [NSColor lightGrayColor];
        self.codeBorderColor            = [NSColor blackColor];;
        self.codeBorderWidth            = kDefaultBorderWidth;;
        self.codeBorderRadius           = kDefaultBorderRadius;

        self.preTextColor               = [NSColor blackColor];
        self.preBackgroundColor         = [NSColor lightGrayColor];
        self.preBorderColor             = [NSColor blackColor];
        self.preBorderWidth             = kDefaultBorderWidth;
        self.preBorderRadius            = kDefaultBorderRadius;

        self.linkColor                  = [NSColor blueColor];
        self.underlineLinks             = YES;

        self.listBullet                 = 0x2022;
        self.listIndent                 = kDefaultBulletIndent;

        self.checklistUncheckedFont     = [NSFont systemFontOfSize:kDefaultFontSize];
        self.checklistCheckedFont       = [NSFont systemFontOfSize:kDefaultFontSize];
        self.checklistCheckedTextColor  = [NSColor darkGrayColor];
        self.checklistUncheckedTextColor  = [NSColor blackColor];
        self.checklistBackgroundColor   = [NSColor lightGrayColor];
        self.checklistBorderColor       = [NSColor blackColor];
        self.checklistBorderWidth       = kDefaultBorderWidth;
        self.checklistBorderRadius      = kDefaultBorderRadius;
        
        self.checklistUncheckedMark     = 0x25ce;
        self.checklistCheckedMark       = 0x25c9;
        self.checklistIndent            = kDefaultBulletIndent;
    }

    return self;
}

@end
