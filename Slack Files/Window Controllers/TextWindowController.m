//
//  TextWindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/6/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "TextWindowController.h"

#import "File.h"
#import "PostsLayoutManager.h"
#import "PostsProcessor.h"
#import "Team.h"

@interface TextWindowController ()

@property   IBOutlet    NSTextView  *textView;

@end

@implementation TextWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.textView.textContainerInset = NSMakeSize(20.0, 20.0);
    self.textView.font = [NSFont systemFontOfSize:16.0];

    [self loadTextContent];
}

- (void)loadTextContent
{
    [self loadContentWithCompletion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data)
        {
            if ([@"Post" isEqualToString:self.file.prettyType])
            {
                NSDictionary        *post = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                PostsProcessor      *processor = [PostsProcessor new];
                NSAttributedString  *text = [processor attributedStringFromPost:post];
                PostsLayoutManager  *layoutManager = [PostsLayoutManager new];

                layoutManager.theme = [PostsProcessor defaultTheme];

                [self.textView.textContainer setLineFragmentPadding:0.0];
                [self.textView.textContainer replaceLayoutManager:layoutManager];
                [self.textView.textStorage appendAttributedString:text];
            }
            else
            {
                NSString    *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                self.textView.font = [self fontForFileType];
                self.textView.string = string;
            }
        }

    }];
}

- (NSFont *)fontForFileType
{
    NSFont              *font = [NSFont systemFontOfSize:18.0];
    NSDictionary        *metadata = [NSJSONSerialization JSONObjectWithData:self.file.jsonBlob options:0 error:nil];
    NSString            *type = metadata[@"filetype"];
    NSArray<NSString *> *monoTypes = @[ @"applescript", @"boxnote", @"c", @"csharp", @"cpp", @"css",
                                        @"csv", @"clojure", @"coffeescript", @"cfm", @"d", @"dart",
                                        @"diff", @"dockerfile", @"erlang", @"fsharp", @"fortran", @"go",
                                        @"groovy", @"html", @"handlebars", @"haskell", @"haxe", @"java",
                                        @"javascript", @"kotlin", @"latex", @"lisp", @"lua", @"markdown",
                                        @"matlab", @"mumps", @"ocaml", @"objc", @"php", @"pascal", @"perl",
                                        @"pig", @"powershell", @"puppet", @"python", @"r", @"ruby",
                                        @"rust", @"sql", @"sass", @"scala", @"scheme", @"shell",
                                        @"smalltalk", @"swift", @"tsv", @"vb", @"vbscript", @"velocity",
                                        @"verilog", @"xml", @"yaml" ];

    for (NSString *monoType in monoTypes)
    {
        if ([monoType isEqualToString:type])
        {
            font = [NSFont userFixedPitchFontOfSize:16.0];
        }
    }

    return font;
}

@end

