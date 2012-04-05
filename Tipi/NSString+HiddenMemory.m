//
//  NSString+HiddenMemory.m
// hiddenMemory Core Library
//
//  Created by Chris Ross on 03/06/2010.
//  Copyright 2010 hiddenMemory Ltd. All rights reserved.
//

#import "NSString+HiddenMemory.h"
#import "RegexKitLite.h"

@implementation NSString (HiddenMemory)

+ (NSString*)bytesToHuman:(size_t)value {
	if( value < 1024 ) {
		return [NSString stringWithFormat:@"%db", value];
	}
	else if( value < (1024*(1024*10)) ) {
		return [NSString stringWithFormat:@"%dKb", (value / 1024)];
	}
	else if( value < (1024*1024*1024) ) {
		return [NSString stringWithFormat:@"%dMb", (value / (1024*1024))];
	}
	else 
		return [NSString stringWithFormat:@"%fGb", (value / (1024*1024*1024.0))];
	return @"";
}

- (NSString *)stringByEncodingXMLEntities {
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

- (BOOL)isURL {
	if( [self length] > 0 && 
		([self rangeOfString:@"http://"].location == 0 || [self rangeOfString:@"https://"].location == 0) ) {
        return YES;
    }
    return NO;
}
- (NSArray*)listOfURLS {
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

- (NSComparisonResult)emojiiLengthCompare:(NSString*)other {
	if( [self length] < [other length] ) {
		return NSOrderedDescending;
	}
	else if( [self length] > [other length] ) {
		return NSOrderedAscending;
	}
	return NSOrderedSame;
}

+ (NSArray*)emojiTransformMapOrdered {
    NSArray *transformMap = [NSArray arrayWithObjects:
                             @"\ue056", 
                             @"\ue416", 
                             @"\ue059", 
                             @"\ue40d",
                             @"\ue105",
                             @"\ue413",
                             @"\ue415",
                             @"\ue11a",
                             @"\ue410",
                             @"\ue417",
                             @"\ue418",
                             @"\ue022",
                             @"\ue406", 
                             @"\ue414", 
                             @"\ue020", 
                             @"\ue12b", 
                             @"\ue057",                             
                             nil];
    return transformMap;
}

+ (NSDictionary*)emojiTransformMap {
    NSDictionary *transformMap = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"\ue056", @":-)",
								  @"\ue056", @":)",
								  @"\ue056", @":]",
								  @"\ue056", @"=)",
								  @"\ue416", @">:(",
								  @"\ue416", @">:-(",
								  @"\ue059", @":-(",
								  @"\ue059", @":(",
								  @"\ue059", @":[", 
								  @"\ue059", @"=(",
								  @"\ue40d", @":/",
								  @"\ue40d", @":-/",
								  @"\ue40d", @":\\",
								  @"\ue40d", @":-\\",
								  @"\ue105", @":-P",
								  @"\ue105", @":P",
								  @"\ue105", @"=P",
								  @"\ue413", @":'(",
								  @"\ue415", @":-D",
								  @"\ue415", @":D",
								  @"\ue415", @"=D",
								  @"\ue11a", @"3:)",
								  @"\ue11a", @"3:-)",
								  @"\ue410", @":-O",
								  @"\ue410", @":O",
								  @"\ue417", @":3",
								  @"\ue405", @";)",
								  @"\ue405", @";-)",
								  @"\ue418", @":-*",
								  @"\ue418", @":*",
								  @"\ue022", @"<3",
								  @"\ue415", @"^_^",
								  @"\ue406", @">:O",
								  @"\ue406", @">:-O",
								  @"\ue414", @"-_-",
								  @"\ue020", @"O.o",
								  @"\ue12b", @":|]",
								  
								  @"\ue057", @"8-)",
								  @"\ue057", @"8)",
								  @"\ue057", @"B-)",
								  @"\ue057", @"B)",
								  @"\ue057", @"8-|",
								  @"\ue057", @"8|",
								  @"\ue057", @"B-|",
								  @"\ue057", @"B|",
								  
								  // @"pacman",   @":v",
								  // @"angel",    @"O:)",
								  // @"angel",    @"O:-)",
								  
								  nil];

    return transformMap;
}

+ (NSString*)stringByTransformingToEmoji:(NSString*)_transform {
	NSMutableString *transform = [NSMutableString stringWithString:_transform];
	
    NSDictionary *transformMap = [NSString emojiTransformMap];
		
	NSArray *emoticons = [[transformMap allKeys] sortedArrayUsingSelector:@selector(emojiiLengthCompare:)];
	
	if( [transform rangeOfString:@" "].location != NSNotFound ) {
		for( NSString *emoticon in emoticons ) {
			[transform replaceOccurrencesOfString:[NSString stringWithFormat:@" %@", emoticon]
									   withString:[transformMap objectForKey:emoticon]
										  options:NSCaseInsensitiveSearch
											range:NSMakeRange(0, [transform length])];
		}
	}
	else if( [transformMap objectForKey:transform] ) {
		return [transformMap objectForKey:transform];
	}
	return transform;
}

- (NSString*)tagWithAttribute:(NSString*)key value:(NSString*)value content:(id(^)())content {
	return [self tagWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:value, key, nil] content:content];
}
- (NSString*)tagWithAttributes:(NSDictionary*)values content:(id(^)())content {
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

- (NSString*)tagWithAttribute:(NSString*)key value:(NSString*)value body:(NSString*)content {
    return [self tagWithAttribute:key value:value content:^id() {
        return content;
    }];
}

- (NSString*)tagWithAttributes:(NSDictionary*)values body:(NSString*)content {
    return [self tagWithAttributes:values content:^id() {
        return content;
    }];
}

- (NSString*)escapeHTML {
	NSMutableString *target = [NSMutableString stringWithString:self];
	[target replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, [target length])];
	[target replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, [target length])];
	[target replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, [target length])];
	return target;
}
- (NSString*)stringByAddingHTMLFormattingToPlainCharacters {
	NSMutableString *target = [NSMutableString stringWithString:self];
	[target replaceOccurrencesOfString:@"\n" withString:@"<br />\n" options:NSLiteralSearch range:NSMakeRange(0, [target length])];
	return target;
}

- (NSString*)stringByUppercasingFirstCharacter {
    if( [self length] ) {
        return [NSString stringWithFormat:@"%@%@", [[self substringToIndex:1] uppercaseString], [self substringFromIndex:1]];
    }
    return self;
}
- (NSString*)stringByExpandingTokensInDictionary:(NSDictionary*)tokens {
    NSString *contents = self;
    if( tokens ) {
        for( NSString *key in [tokens allKeys] ) {
			contents = [contents stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key]
														   withString:[NSString stringWithFormat:@"%@", [tokens objectForKey:key]]];
		}
	}
	return contents;
}

+ (NSString*)stringByExpandingFormat:(NSString*)format withTokens:(NSDictionary*)tokens {
    return [format stringByExpandingTokensInDictionary:tokens];
}

+ (NSString*)stringByCreatingWhitespaceOfLength:(NSInteger)length {
	return [@"\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t" substringToIndex:length];
}

- (NSString*)stringByTrimmingWhitespace {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString*)removePrefix:(NSString*)prefix suffix:(NSString*)suffix {
	NSString *str = self;
	
	if( [str hasPrefix:prefix] ) {
		str = [str stringByReplacingCharactersInRange:NSMakeRange(0, [prefix length]) withString:@""];
	}
	
	if( [str hasSuffix:suffix] ) {
		str = [str stringByReplacingCharactersInRange:NSMakeRange([str length] - [suffix length], [suffix length]) withString:@""];
	}

	return str;
}

@end
