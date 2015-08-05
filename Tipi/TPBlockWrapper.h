//
// Created by Chris Ross on 04/08/2015.
// Copyright (c) 2015 hiddenMemory Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPTemplateNode;

typedef NSString *(^TPExpansionBlock)( TPTemplateNode *node, NSMutableDictionary *environment );

@interface TPBlockWrapper : NSObject
+ (TPBlockWrapper *)wrap:(TPExpansionBlock)block;

- (instancetype)initWithBlock:(TPExpansionBlock)block;
- (NSString*)expandNode:(TPTemplateNode *)node environment:(NSMutableDictionary *)environment;
@end