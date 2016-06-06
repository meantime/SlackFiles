//
//  VideoWindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/5/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "VideoWindowController.h"

@import AVFoundation;
@import AVKit;

#import "File.h"
#import "Team.h"

@interface VideoWindowController () <NSWindowDelegate>

@property   IBOutlet    AVPlayerView    *playerView;

@property   File    *file;

@end

@implementation VideoWindowController

+ (instancetype)windowControllerForFile:(File *)file
{
    VideoWindowController   *result = [[VideoWindowController alloc] initWithWindowNibName:@"VideoWindowController"];

    result.file = file;

    return result;
}

- (void)dealloc
{
    [self.playerView.player removeObserver:self forKeyPath:@"status"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.window.title = self.file.title;

    NSDictionary    *metadata = [NSJSONSerialization JSONObjectWithData:self.file.jsonBlob options:0 error:nil];
    NSDictionary    *headers = @{ @"Bearer" : self.file.team.apiToken };
    NSURL           *url = [NSURL URLWithString:metadata[@"url_private"]];
    AVURLAsset      *asset = [AVURLAsset URLAssetWithURL:url options:@{ @"AVURLAssetHTTPHeaderFieldsKey" : headers }];
    AVPlayerItem    *item = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer        *player = [[AVPlayer alloc] initWithPlayerItem:item];

    [player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];

    self.playerView.player = player;
    self.playerView.showsFullScreenToggleButton = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object != self.playerView.player)
    {
        return;
    }

    if (AVPlayerStatusReadyToPlay == [change[NSKeyValueChangeNewKey] integerValue])
    {
        [self.playerView.player play];
    }
}

#pragma mark - <NSWindowDelegate>

- (BOOL)windowShouldClose:(id)sender
{
    [self.playerView.player pause];

    [NSAppDelegate windowWillClose:self];

    return YES;
}

@end
