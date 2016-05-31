//
//  NSURL+QueryArgs.h
//  Slack Files
//
//  Created by Chris DeSalvo on 5/30/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (QueryArgs)

- (NSDictionary *)dictionaryFromQueryArgs;

@end
