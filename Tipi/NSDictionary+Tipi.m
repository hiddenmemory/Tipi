//
// Created by Chris Ross on 04/08/2015.
// Copyright (c) 2015 hiddenMemory Ltd. All rights reserved.
//

#import "NSDictionary+Tipi.h"

@implementation NSDictionary (Tipi)

- (id)tp_objectForPath:(NSString*)path {
    NSDictionary *root = self;
    NSArray *parts = [path componentsSeparatedByString:@"."];

    for( int i = 0; i < [parts count] && root != nil; i++ ) {
        NSString *part = parts[i];
        if( i < ([parts count] - 1) ) {
            if( [[root class] isSubclassOfClass:[NSMutableDictionary class]] ) {
                if( root[part] == nil ) {
                    ((NSMutableDictionary *) root)[part] = [NSMutableDictionary dictionary];
                }
            }
            else {
                root = nil;
            }
            root = root[part];
        }
        else {
            return root[part];
        }
    }
    return nil;
}

@end