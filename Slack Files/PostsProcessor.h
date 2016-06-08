//
//  PostsProcessor.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/7/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Foundation;

@class PostsTheme;

@interface PostsProcessor : NSObject

@property (nullable)    PostsTheme  *theme;

+ (nonnull PostsTheme *)defaultTheme;

- (nonnull NSAttributedString *)attributedStringFromPost:(nonnull NSDictionary *)document;

@end

@interface PostsTheme : NSObject

@property (nullable)    NSColor         *textColor;
@property (nullable)    NSColor         *backgroundColor;

@property               NSTextAlignment h1Alignment;
@property               NSTextAlignment h2Alignment;
@property               NSTextAlignment h3Alignment;
@property (nullable)    NSFont          *h1Font;
@property (nullable)    NSFont          *h2Font;
@property (nullable)    NSFont          *h3Font;

@property               NSTextAlignment paragraphAlignment;
@property (nullable)    NSFont          *baseFont;
@property (nullable)    NSFont          *boldFont;
@property (nullable)    NSFont          *italicFont;
@property (nullable)    NSFont          *boldItalicFont;

@property (nullable)    NSFont          *monospaceFont;
@property (nullable)    NSFont          *monospaceBoldFont;
@property (nullable)    NSFont          *monospaceItalicFont;
@property (nullable)    NSFont          *monospaceBoldItalicFont;

@property (nullable)    NSColor         *codeTextColor;
@property (nullable)    NSColor         *codeBackgroundColor;
@property (nullable)    NSColor         *codeBorderColor;
@property               CGFloat         codeBorderWidth;
@property               CGFloat         codeBorderRadius;

@property (nullable)    NSColor         *preTextColor;
@property (nullable)    NSColor         *preBackgroundColor;
@property (nullable)    NSColor         *preBorderColor;
@property               CGFloat         preBorderWidth;
@property               CGFloat         preBorderRadius;

@property (nullable)    NSColor         *linkColor;
@property               BOOL            underlineLinks;

@property               unichar         listBullet;
@property               CGFloat         listIndent;

@property (nullable)    NSFont          *checklistUncheckedFont;
@property (nullable)    NSFont          *checklistCheckedFont;
@property (nullable)    NSColor         *checklistCheckedTextColor;
@property (nullable)    NSColor         *checklistUncheckedTextColor;
@property (nullable)    NSColor         *checklistBackgroundColor;
@property (nullable)    NSColor         *checklistBorderColor;
@property               CGFloat         checklistBorderWidth;
@property               CGFloat         checklistBorderRadius;

@property               unichar         checklistUncheckedMark;
@property               unichar         checklistCheckedMark;
@property               CGFloat         checklistIndent;

@end
