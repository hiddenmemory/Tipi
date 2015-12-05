//
//  NSString+Markdown.h
//  OCDiscount
//
//  Created by Sumardi Shukor on 10/12/13.
//  Copyright (c) 2013 Software Machine Development. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * `NSString+Markdown` is a `NSString` category to convert markdown string to an HTML string.
 *
 * @since Available in 0.1.0 or later.
 */
@interface NSString (Markdown)

/**
 * Converts the given markdown string to an HTML string.
 *
 * @deprecated This method will be removed in 0.3.0, use [htmlStringFromMarkdown:](#//api/name/htmlStringFromMarkdown) instead.
 * @since Available in 0.1.0 and 0.2.0.
 * @returns Returns an HTML string, or `nil` if the string couldn't be converted.
 */
- (NSString *)htmlWithMarkdown;

/**
 * Converts the given markdown string to an HTML string.
 *
 * @since Available in 0.2.0 or later
 * @returns Returns an HTML string, or `nil` if the string couldn't be converted.
 */
- (NSString *)htmlStringFromMarkdown;

@end
