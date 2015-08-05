//
// Created by Chris Ross on 04/08/2015.
// Copyright (c) 2015 hiddenMemory Ltd. All rights reserved.
//

#import "TPBlockWrapper.h"
#import "TPTemplateNode.h"

@interface TPBlockWrapper ()
@property (copy) TPExpansionBlock block;
@end

@implementation TPBlockWrapper
+ (TPBlockWrapper *)wrap:(TPExpansionBlock)block {
    return [[TPBlockWrapper alloc] initWithBlock:block];
}
- (instancetype)initWithBlock:(TPExpansionBlock)block {
    self = [super init];
    if( self ){
        self.block = block;
    }
    return self;
}

- (NSString *)expandNode:(TPTemplateNode *)node environment:(NSMutableDictionary *)environment {
    if( self.block ) {
        return self.block(node, environment);
    }
    return @"";
}
@end