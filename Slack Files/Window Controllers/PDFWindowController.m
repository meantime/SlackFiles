//
//  PDFWindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/6/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "PDFWindowController.h"

@import Quartz;

@interface PDFWindowController ()

@property   IBOutlet    PDFView     *pdfView;

@end

@implementation PDFWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];

    [self loadPDFContent];
}

- (void)loadPDFContent
{
    [self loadContentWithCompletion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data)
        {
            PDFDocument *document = [[PDFDocument alloc] initWithData:data];

            self.pdfView.document = document;
        }
    }];
}

@end
