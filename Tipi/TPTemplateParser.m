//
//  TPTemplateParser.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import "TPTemplateParser.h"
#import "TPTemplateNode.h"
#import "TPMarkdownDataParser.h"

#import "NSString+Tipi.h"
#import "NSArray+Tipi.h"

@interface TPTemplateParser () {
	TPTemplateNode *root;
	
	NSString *tagStart, *tagEnd;
	NSString *tagBlockOpen, *tagBlockClose;
}
- (id)initWithFileAtPath:(NSString*)path;
- (void)parseContent:(NSMutableString*)content parent:(TPTemplateNode*)parent;
- (BOOL)parseTag:(NSMutableString*)content parent:(TPTemplateNode*)parent;
@end

@implementation TPTemplateParser
+ (TPTemplateParser*)parserForFile:(NSString*)path {
	return [[[self class] alloc] initWithFileAtPath:path];
}
- (id)initWithFileAtPath:(NSString*)path {
	self = [super init];
	if( self ) {
		root = [TPTemplateNode node];
		
		tagStart = @"{{";
		tagBlockOpen = @"#";
		tagBlockClose = @"/";
		tagEnd = @"}}";
		
		NSMutableString *content = [NSMutableString stringWithContentsOfFile:path 
																	encoding:NSUTF8StringEncoding
																	   error:nil];
		
		[self parseContent:content parent:root];
		
		NSLog(@"Node: %@", [root description]);
	}
	return self;
}
- (NSString*)expansionUsingEnvironment:(NSDictionary*)values {
	NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithDictionary:values];
	
	[environment setObject:[^NSString*( TPTemplateNode *node, NSMutableDictionary *environment, NSArray *parameters ) { return @""; } copy]
					forKey:@"bind"];
	
	[environment setObject:[^NSString*( TPTemplateNode *node, NSMutableDictionary *environment, NSArray *parameters ) {
		if( [node.childNodes count] > 0 ) {
			// If there is one or more child nodes, we assume that this is an expansion block
			NSString *key = [[node.values objectAtIndex:0] lowercaseString];
			NSMutableDictionary *freshEnvironment = [NSMutableDictionary dictionaryWithDictionary:environment];
			
			[environment setObject:[^NSString*( TPTemplateNode *currentNode, NSMutableDictionary *environment, NSArray *parameters ) {
				NSMutableDictionary *invokeEnvironment = [NSMutableDictionary dictionaryWithDictionary:freshEnvironment];

				// Capture {{this}}
				[invokeEnvironment setObject:[currentNode.childNodes tp_templateNodesExpandedUsingEnvironment:freshEnvironment]
									  forKey:@"this"];
				
				// Capture each parameter: this maps the {{def NAME PARAM1}} -> value provided in parameters
				[[node.values subarrayWithRange:NSMakeRange(1, [node.values count] - 1)] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					[invokeEnvironment setObject:[parameters objectAtIndex:idx] forKey:[obj lowercaseString]];
				}];
				
				// This walks the node on which the def is being invoked to see if there are any bind commands
				for( TPTemplateNode *bindNode in currentNode.childNodes ) {
					if( [bindNode.name isEqualToString:@"bind"] ) {
						[bindNode.childNodes enumerateObjectsUsingBlock:^(TPTemplateNode *obj, NSUInteger idx, BOOL *stop) {
							[invokeEnvironment setObject:[obj expansionUsingEnvironment:freshEnvironment]
												  forKey:[[bindNode.values objectAtIndex:0] lowercaseString]];
						}];
					}
				}
				
				// Expand and return the result
				return [node.childNodes tp_templateNodesExpandedUsingEnvironment:invokeEnvironment];
			} copy] forKey:key];
		}
		else {
			/// If there are no child nodes, we set a value in the environment
			[environment setObject:[node.values objectAtIndex:1] forKey:[[node.values objectAtIndex:0] lowercaseString]];

			NSLog(@"Environment: %@", environment);
		}
		
		return @"";
	} copy] forKey:@"def"];
	
	return [[root expansionUsingEnvironment:environment] stringByTrimmingWhitespace];
}
- (void)parseContent:(NSMutableString*)content parent:(TPTemplateNode*)parent {
	while( [content length] ) {
		NSRange range = [content rangeOfString:tagStart];
		BOOL shouldParseTag = YES;
		
		if( range.location == NSNotFound ) {
			range.location = [content length];
			shouldParseTag = NO;
		}
		
		TPTemplateNode *node = [TPTemplateNode node];
		node.type = TPNodeText;
		node.name = @"";
		node.originalValue = [content substringToIndex:range.location];
		[node.values addObject:node.originalValue];
		[parent.childNodes addObject:node];
		
		[content deleteCharactersInRange:NSMakeRange(0, range.location)];
		
		if( shouldParseTag ) {
			if( [self parseTag:content parent:parent] ) {
				return;
			}
		}
	}
}
- (BOOL)parseTag:(NSMutableString*)content parent:(TPTemplateNode*)parent {
	if( [content hasPrefix:tagStart] ) {
		NSRange tagContentRange = [content rangeOfString:tagEnd];
		
		if( tagContentRange.location != NSNotFound ) {
			TPTemplateNode *node = [TPTemplateNode node];
			node.originalValue = [content substringToIndex:tagContentRange.location + tagEnd.length];
			
			NSMutableArray *parts = [NSMutableArray array];
			NSString *stringToParse = [node.originalValue removePrefix:tagStart suffix:tagEnd];
			
			while( [stringToParse length] ) {
				stringToParse = [stringToParse stringByTrimmingWhitespace];
				
				if( [stringToParse hasPrefix:@"\""] || [stringToParse hasPrefix:@"'"] ) {
					// If we match a comment character, match until the next non-escaped version, otherwise until end of the string
					unichar matchCharacter = [stringToParse characterAtIndex:0];
					BOOL success = NO;

					for( NSUInteger i = 1; i < [stringToParse length]; i++ ) {
						unichar c = [stringToParse characterAtIndex:i];
						if( c == matchCharacter && [stringToParse characterAtIndex:i - 1] != '\\' ) {
							[parts addObject:[stringToParse substringWithRange:NSMakeRange(1, i - 1)]];
							stringToParse = [stringToParse substringFromIndex:i + 1];
							success = YES;
							break;
						}
					}
					
					if( success == NO ) {
						// If we don't find the terminating character, we chomp till the end of the string
						[parts addObject:stringToParse];
						stringToParse = @"";
					}
				}
				else {
					// Chomp until the next space
					NSRange range = [stringToParse rangeOfString:@" "];
					NSString *nextToken = (range.location == NSNotFound ? stringToParse : [stringToParse substringToIndex:range.location]);
					
					[parts addObject:nextToken];
					
					if( range.location != NSNotFound ) {
						stringToParse = [stringToParse substringFromIndex:[nextToken length]];
					}
					else {
						// We hit the end of the string
						break;
					}
				}
			}
			
			[content deleteCharactersInRange:NSMakeRange(0, node.originalValue.length)];
			
			if( [[parts objectAtIndex:0] hasPrefix:tagBlockOpen] ) {
				if( [[parts objectAtIndex:0] isEqualToString:tagBlockOpen] ) {
					[parts removeObjectAtIndex:0];
				}
				else {
					[parts replaceObjectAtIndex:0 withObject:[[parts objectAtIndex:0] removePrefix:tagBlockOpen suffix:nil]];
				}
				
				node.type = TPNodeDefinition;
				node.name = [parts objectAtIndex:0];
				
				if( [parts count] > 1 ) {
					[node.values addObjectsFromArray:[parts subarrayWithRange:NSMakeRange(1, [parts count] - 1)]];
				}
				
				[parent.childNodes addObject:node];
				
				if( [content characterAtIndex:0] == '\n' ) {
					[content deleteCharactersInRange:NSMakeRange(0, 1)];
				}
				
				[self parseContent:content parent:node];
			}
			else if( [[parts objectAtIndex:0] hasPrefix:tagBlockClose] ) {
				if( [[parts objectAtIndex:0] isEqualToString:tagBlockClose] ) {
					[parts removeObjectAtIndex:0];
				}
				else {
					[parts replaceObjectAtIndex:0 withObject:[[parts objectAtIndex:0] removePrefix:tagBlockClose suffix:nil]];
				}
				
				if( [content characterAtIndex:0] == '\n' ) {
					[content deleteCharactersInRange:NSMakeRange(0, 1)];
				}
				
				return YES;
			}
			else {
				node.type = TPNodeApplication;
				node.name = [parts objectAtIndex:0];
				if( [parts count] > 1 ) {
					[node.values addObjectsFromArray:[parts subarrayWithRange:NSMakeRange(1, [parts count] - 1)]];
				}
				
				[parent.childNodes addObject:node];
			}
		}
		else {
			[NSException raise:@"TagParseError" format:@"Error parsing tag"];
		}
	}
	return NO;
}
@end
