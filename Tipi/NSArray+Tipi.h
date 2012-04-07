//
//  NSArray+Tipi.h
//  Tipi
//
//  Created by Chris Ross on 07/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPTemplateNode;

@interface NSArray (Tipi)

- (NSString*)tp_templateNodesExpandedUsingEnvironment:(NSMutableDictionary*)environment;

@end
