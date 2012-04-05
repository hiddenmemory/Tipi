//
//  TPTemplateParser.h
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPTemplateParser : NSObject
+ (TPTemplateParser*)parserForFile:(NSString*)path;
- (NSString*)expansionUsingEnvironment:(NSDictionary*)values;
@end
