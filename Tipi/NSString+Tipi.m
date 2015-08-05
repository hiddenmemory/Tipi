//
//  NSString+Tipi.m
//  Tipi Core Library
//
//  Created by Chris Ross on 03/06/2010.
//  Copyright 2010 hiddenMemory Ltd. All rights reserved.
//

#import "NSString+Tipi.h"
#import "RegexKitLite.h"

@implementation NSString (Tipi)

- (NSString *)tp_stringByEncodingXMLEntities {
    // Scanner
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *temp;
    NSCharacterSet *characters = [NSCharacterSet characterSetWithCharactersInString:@"&\"'<>"];
    [scanner setCharactersToBeSkipped:nil];

    // Scan
    while (![scanner isAtEnd]) {

        // Get non new line or whitespace characters
        temp = nil;
        [scanner scanUpToCharactersFromSet:characters intoString:&temp];
        if (temp) [result appendString:temp];

        // Replace with encoded entities
        if ([scanner scanString:@"&" intoString:NULL])
            [result appendString:@"&amp;"];
        else if ([scanner scanString:@"'" intoString:NULL])
            [result appendString:@"&apos;"];
        else if ([scanner scanString:@"\"" intoString:NULL])
            [result appendString:@"&quot;"];
        else if ([scanner scanString:@"<" intoString:NULL])
            [result appendString:@"&lt;"];
        else if ([scanner scanString:@">" intoString:NULL])
            [result appendString:@"&gt;"];

    }

    // Return
    NSString *retString = [NSString stringWithString:result];
    return retString;
}

- (BOOL)tp_isURL {
    if( [self length] > 0 &&
            ([self rangeOfString:@"http://"].location == 0 || [self rangeOfString:@"https://"].location == 0) ) {
        return YES;
    }
    return NO;
}
- (NSArray*)tp_listOfURLS {
    NSString *url = @"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))";
    NSMutableArray *urls = nil;

    for( NSArray *_urls in [self arrayOfCaptureComponentsMatchedByRegex:url] ) {
        if( [_urls count] ) {
            if( urls == nil ) {
                urls = [NSMutableArray array];
            }
            [urls addObject:[_urls objectAtIndex:0]];
        }
    }

    return urls;
}

- (NSString*)tp_tagWithAttribute:(NSString*)key value:(NSString*)value content:(id(^)())content {
    return [self tp_tagWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:value, key, nil] content:content];
}
- (NSString*)tp_tagWithAttributes:(NSDictionary*)values content:(id(^)())content {
    NSString *attributeString = @"";
    NSString *contentString = content();

    if( [values count] ) {
        NSMutableArray *attributes = [NSMutableArray array];
        for( NSString *key in [values allKeys] ) {
            [attributes addObject:[NSString stringWithFormat:@"%@=\"%@\"", key, [values objectForKey:key]]];
        }
        attributeString = [attributes componentsJoinedByString:@" "];
    }

    return [NSString stringWithFormat:@"<%@%@%@>%@</%@>",
                                      self,
                                      ([attributeString length] > 0 ? @" " : @""),
                                      ([attributeString length] > 0 ? attributeString : @""),
                                      (contentString ? contentString : @""),
                                      self];
}

- (NSString*)tp_tagWithAttribute:(NSString*)key value:(NSString*)value body:(NSString*)content {
    return [self tp_tagWithAttribute:key value:value content:^id() {
        return content;
    }];
}

- (NSString*)tp_tagWithAttributes:(NSDictionary*)values body:(NSString*)content {
    return [self tp_tagWithAttributes:values content:^id() {
        return content;
    }];
}

- (NSString*)tp_escapeHTML {
    NSMutableString *target = [NSMutableString stringWithString:self];
    [target replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, [target length])];
    [target replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, [target length])];
    [target replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, [target length])];
    return target;
}
- (NSString*)tp_stringByAddingHTMLFormattingToPlainCharacters {
    NSMutableString *target = [NSMutableString stringWithString:self];
    [target replaceOccurrencesOfString:@"\n"
                            withString:@"<br />\n"
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, [target length])];
    return target;
}

- (NSString*)tp_stringByUppercasingFirstCharacter {
    if( [self length] ) {
        return [NSString stringWithFormat:@"%@%@", [[self substringToIndex:1] uppercaseString], [self substringFromIndex:1]];
    }
    return self;
}
- (NSString*)tp_stringByExpandingTokensInDictionary:(NSDictionary*)tokens {
    NSString *contents = self;
    if( tokens ) {
        for( NSString *key in [tokens allKeys] ) {
            contents = [contents stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key]
                                                           withString:[NSString stringWithFormat:@"%@", [tokens objectForKey:key]]];
        }
    }
    return contents;
}

+ (NSString*)tp_stringByExpandingFormat:(NSString*)format withTokens:(NSDictionary*)tokens {
    return [format tp_stringByExpandingTokensInDictionary:tokens];
}

+ (NSString*)tp_stringByCreatingWhitespaceOfLength:(NSInteger)length {
    return [@"\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t" substringToIndex:length];
}

- (NSString*)tp_stringByTrimmingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString*)tp_stringByRemovingPrefix:(NSString*)prefix suffix:(NSString*)suffix {
    NSString *str = self;

    if( prefix && [str hasPrefix:prefix] ) {
        str = [str stringByReplacingCharactersInRange:NSMakeRange(0, [prefix length]) withString:@""];
    }

    if( suffix && [str hasSuffix:suffix] ) {
        str = [str stringByReplacingCharactersInRange:NSMakeRange([str length] - [suffix length], [suffix length]) withString:@""];
    }

    return str;
}

@end
