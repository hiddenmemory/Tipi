//
//  OCDiscount.h
//  OCDiscount
//
//  Created by Sumardi Shukor on 10/14/13.
//  Copyright (c) 2013 Software Machine Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Markdown.h"

/**
 * The `OCDiscount` class is used to convert markdown string to an HTML string.
 *
 * @since Available in 0.2.0 or later.
 */
@interface OCDiscount : NSObject

/**
 * Converts the markdown in a file at the given path to an HTML string.
 *
 * @since Available in 0.2.0 or later.
 * @param path The path of the file whose contents you want.
 * @param error The error that was encountered.
 * @returns Returns an HTML string or `nil` if the string couldn't be converted.
 * @see convertMarkdownFileAtURL:error:
 */
+ (NSString *)convertMarkdownFileAtPath:(NSString *)path error:(NSError **)error;

/**
 * Converts the markdown in a file at the given url to an HTML string.
 *
 * @since Available in 0.2.0 or later.
 * @param url The url of the file whose contents you want.
 * @param error The error that was encountered.
 * @returns Returns an HTML string, or `nil` if the string couldn't be converted.
 * @see convertMarkdownFileAtPath:error:
 */
+ (NSString *)convertMarkdownFileAtURL:(NSURL *)url error:(NSError **)error;

/**
 * Converts the markdown string to an HTML string.
 *
 * @since Available in 0.2.0 or later.
 * @returns Returns an HTML string, or `nil` if the string couldn't be converted.
 */
+ (NSString *)convertMarkdownString:(NSString *)string;

@end
