//
//  OCDiscount.m
//  OCDiscount
//
//  Created by Sumardi Shukor on 10/14/13.
//  Copyright (c) 2013 Software Machine Development. All rights reserved.
//

#import "OCDiscount.h"
#import "markdown.h"

@implementation OCDiscount

+ (NSString *)convertMarkdownFileAtPath:(NSString *)path error:(NSError **)error
{
    NSString *string = [NSString stringWithContentsOfFile:path
                                                 encoding:NSUTF8StringEncoding
                                                    error:error];
    
    return [OCDiscount convertMarkdownString:string];
}

+ (NSString *)convertMarkdownFileAtURL:(NSURL *)url error:(NSError **)error
{
    NSString *string = [NSString stringWithContentsOfURL:url
                                                encoding:NSUTF8StringEncoding
                                                   error:error];
    
    return [OCDiscount convertMarkdownString:string];
}

+ (NSString *)convertMarkdownString:(NSString *)string
{
    NSString *html = nil;
    
    if (string != nil) {
        char *markdownUTF8 = (char*)[string UTF8String];
        Document *document = mkd_string(markdownUTF8, (int)strlen(markdownUTF8), 0);
        
        if (document) {
            if (mkd_compile(document, 0)) {
                char *htmlUTF8;
                int htmlUTF8Len = mkd_document(document, &htmlUTF8);
                if (htmlUTF8Len != EOF) {
                    html = [[NSString alloc] initWithBytes:htmlUTF8
                                                    length:htmlUTF8Len
                                                  encoding:NSUTF8StringEncoding];
                }
                mkd_cleanup(document);
            }
        }
    }

    return html;
}

@end
