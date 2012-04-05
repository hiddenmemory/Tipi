//
//  TPTextDataParser.h
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import "TPParser.h"

@interface TPTextDataParser : TPParser
+ (TPTextDataParser*)parserForFile:(NSString*)path;
@end
