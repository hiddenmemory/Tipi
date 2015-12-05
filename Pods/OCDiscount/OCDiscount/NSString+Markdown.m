//
//  NSString+Markdown.m
//  OCDiscount
//
//  Created by Sumardi Shukor on 10/12/13.
//  Copyright (c) 2013 Software Machine Development. All rights reserved.
//

#import "NSString+Markdown.h"
#import "OCDiscount.h"

@implementation NSString (Markdown)

- (NSString *)htmlWithMarkdown
{
    return [OCDiscount convertMarkdownString:self];
}

- (NSString *)htmlStringFromMarkdown
{
    return [OCDiscount convertMarkdownString:self];
}

@end
