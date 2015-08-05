//
//  _TPMarkdownDataParser.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import "_TPMarkdownDataParser.h"
#import "OCDiscount.h"

@implementation _TPMarkdownDataParser

- (NSDictionary*)values {
    NSDictionary *values = [super values];
    NSMutableDictionary *markdownValues = [NSMutableDictionary dictionary];

    for( NSString *key in [values allKeys] ) {
        NSString *originalValue = values[key];
        NSMutableString *htmlSnippet = [NSMutableString stringWithString:[OCDiscount convertMarkdownString:originalValue]];

        if( [htmlSnippet hasPrefix:@"<p>"] ) {
            [htmlSnippet deleteCharactersInRange:NSMakeRange(0, [@"<p>" length])];
        }
        if( [htmlSnippet hasSuffix:@"</p>"] ) {
            NSUInteger tagLength = [@"</p>" length];
            [htmlSnippet deleteCharactersInRange:NSMakeRange([htmlSnippet length] - tagLength, tagLength)];
        }

        markdownValues[key] = htmlSnippet;
    }

    return markdownValues;
}

@end
