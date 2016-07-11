# Slack Files

This app will let you browse all of the files you have access to in your Slack teams. You can filter by location
(channel, group, etc) and by media type (image, video, etc).

Once opened, your files can be saved locally to disk or printed. Audio and video media stream on demand.

After the initial sync (which can take a while for teams with a large numbers of files) all updates happen live.

Requires Mac OS X 10.11 or newer.

<img src="Screenshots/screenshot.png" />

# Setup

To build and run the app you'll need a Slack application id and then put the app id and your
shared secret in the file:

`Slack Files/OAuth2/Credentials.h`

it should look something like this:

```objc
//
//  Credentials.h
//

#ifndef Credentials_h
#define Credentials_h

#define kClientId       @"123456789.123456789"
#define kClientSecret   @"01982374890abcdef290374abcdef123"

#endif
```

You can register as a Slack developer and get and get an app id at https://api.slack.com/register.