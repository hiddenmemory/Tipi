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

//#define ParserLog if( NO ) NSLog
#define ParserLog NSLog

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
		
		ParserLog(@"Node: %@", [root description]);
	}
	return self;
}
- (NSString*)expandValue:(id)value environment:(NSMutableDictionary*)currentEnvironment node:(TPTemplateNode*)currentNode {
	ParserLog(@"Looking to expand value: '%@'", value);
	
	if( [[value class] isSubclassOfClass:[NSString class]] ) {
		if( [currentEnvironment objectForKey:[value lowercaseString]] ) {
			value = [currentEnvironment objectForKey:[value lowercaseString]];
		}
		ParserLog(@"Looking for value %@ in current environment", value);
	}
	else {
		NSString *(^expansionBlock)( TPTemplateNode *node, NSMutableDictionary *global ) = value;
		value = expansionBlock(currentNode, currentEnvironment);
		ParserLog(@"Expanded value %@ in current environment", value);
	}
	
	if( value == nil ) {
		value = @"";
	}
	
	return value;
}
- (NSString*)expansionUsingEnvironment:(NSDictionary*)values {
	NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithDictionary:values];
	
	[environment setObject:@"" forKey:@"bind"];
	
	[environment setObject:[^NSString*( TPTemplateNode *node, NSMutableDictionary *environment ) {
		if( [node.values count] ) {
			NSString *key = [[node.values objectAtIndex:0] lowercaseString];
			if( !([key isEqualToString:@"bind"] || [key isEqualToString:@"def"]) ) {
				// Don't allow people to redfine bind or def.
				if( [node.childNodes count] ) {
					// If there is one or more child nodes, we assume that this is an expansion block
					NSMutableDictionary *capturedEnvironment = [NSMutableDictionary dictionaryWithDictionary:environment];
					
					[environment setObject:[^NSString*( TPTemplateNode *currentNode, NSMutableDictionary *currentEnvironment ) {
						NSMutableDictionary *invokeEnvironment = [NSMutableDictionary dictionaryWithDictionary:capturedEnvironment];

						ParserLog(@"Processing node %@", currentNode.name);
						
						// Capture {{this}}
						[invokeEnvironment setObject:[currentNode.childNodes tp_templateNodesExpandedUsingEnvironment:currentEnvironment]
											  forKey:@"this"];
						
						// Capture each parameter: this maps the {{def NAME KEY1=PARAM1}} -> value provided in parameters
						[[node.values subarrayWithRange:NSMakeRange(1, [node.values count] - 1)] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
							NSString *key = [obj lowercaseString];
							id value = nil;

							ParserLog(@"Checking key: %@", key);

							if( [currentNode.valuesMap objectForKey:key] ) {
								value = [currentNode.valuesMap objectForKey:key];
								ParserLog(@"Fetching value %@ from current node", value);
							}
							else if( [node.valuesMap objectForKey:key] ) {
								value = [node.valuesMap objectForKey:key];
								ParserLog(@"Fetching value %@ from def node", value);
							}
							else {
								value = key;
								ParserLog(@"Unable to find value, using key name %@", value);
							}

							[invokeEnvironment setObject:[self expandValue:value
															   environment:currentEnvironment
																	  node:currentNode]
												  forKey:key];
						}];
						
						// This walks the node on which the def is being invoked to see if there are any bind commands
						for( TPTemplateNode *bindNode in currentNode.childNodes ) {
							if( [bindNode.name isEqualToString:@"bind"] && [node.valuesMap objectForKey:[bindNode.values objectAtIndex:0]] ) {
								if( [bindNode.childNodes count] ) {
									[invokeEnvironment setObject:[bindNode.childNodes tp_templateNodesExpandedUsingEnvironment:currentEnvironment]
														  forKey:[[bindNode.values objectAtIndex:0] lowercaseString]];
								}
								else if( [bindNode.values count] > 0 ) {
									[invokeEnvironment setObject:[self expandValue:[bindNode.valuesMap objectForKey:[bindNode.values objectAtIndex:0]] 
																	   environment:currentEnvironment
																			  node:currentNode]
														  forKey:[[bindNode.values objectAtIndex:0] lowercaseString]];
								}
							}
						}
						
						ParserLog(@"Invoke environment: %@ (%@)", invokeEnvironment, currentNode);
						
						// Expand and return the result
						NSString *expansion = [node.childNodes tp_templateNodesExpandedUsingEnvironment:invokeEnvironment];
						ParserLog(@"Expansion for %@ = %@", currentNode.name, expansion);
						return expansion;
					} copy] forKey:key];
				}
				else {
					/// If there are no child nodes, we set a value in the environment
					[environment setObject:[self expandValue:[node.valuesMap objectForKey:[node.values objectAtIndex:0]]
												 environment:environment
														node:node]
									forKey:key];

					ParserLog(@"Environment: %@", environment);
				}
			}
		}
		
		return @"";
	} copy] forKey:@"def"];
	
	return [root expansionUsingEnvironment:environment];
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

- (NSString*)nextToken:(NSMutableString*)stream {
	NSString *nextToken = @"";
	
	NSString *stringToParse = [stream stringByTrimmingWhitespace];
	
	if( [stringToParse hasPrefix:@"\""] || [stringToParse hasPrefix:@"'"] ) {
		// If we match a comment character, match until the next non-escaped version, otherwise until end of the string
		unichar matchCharacter = [stringToParse characterAtIndex:0];
		BOOL success = NO;
		
		for( NSUInteger i = 1; i < [stringToParse length]; i++ ) {
			unichar c = [stringToParse characterAtIndex:i];
			if( c == matchCharacter && [stringToParse characterAtIndex:i - 1] != '\\' ) {
				nextToken = [stringToParse substringWithRange:NSMakeRange(1, i - 1)];
				stringToParse = [stringToParse substringFromIndex:i + 1];
				success = YES;
				break;
			}
		}
		
		if( success == NO ) {
			nextToken = stringToParse;
			stringToParse = @"";
		}
	}
	else if( [stringToParse hasPrefix:@"="] ) {
		stringToParse = [stringToParse substringFromIndex:1];
		nextToken = @"=";
	}
	else {
		// Chomp until the next space
		NSRange range = [stringToParse rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@" \t="]];
		
		nextToken = (range.location == NSNotFound ? stringToParse : [stringToParse substringToIndex:range.location]);
		
		if( range.location != NSNotFound ) {
			stringToParse = [stringToParse substringFromIndex:[nextToken length]];
		}
		else {
			stringToParse = @"";
		}
	}
	
	[stream setString:stringToParse];
	
	return nextToken;
}

- (BOOL)parseTag:(NSMutableString*)content parent:(TPTemplateNode*)parent {
	if( [content hasPrefix:tagStart] ) {
		NSRange tagContentRange = [content rangeOfString:tagEnd];
		
		if( tagContentRange.location != NSNotFound ) {
			TPTemplateNode *node = [TPTemplateNode node];
			node.originalValue = [content substringToIndex:tagContentRange.location + tagEnd.length];
			
			NSMutableArray *parts = [NSMutableArray array];
			NSMutableString *stringToParse = [NSMutableString stringWithString:[node.originalValue removePrefix:tagStart suffix:tagEnd]];

#define STATE_WAITING_FOR_NAME   0
#define STATE_WAITING_FOR_EQUALS 1
#define STATE_WAITING_FOR_VALUE  2

			NSMutableDictionary *baseEnvironment = [NSMutableDictionary dictionary];
			
			NSString *attributeName = @"";
			NSString *attributeValue = @"";
			int       currentState = STATE_WAITING_FOR_NAME;
			
			while( [stringToParse length] ) {
				NSString *token = [self nextToken:stringToParse];

				switch( currentState ) {
					case STATE_WAITING_FOR_NAME:
						if( [token length] ) {
							attributeName = [token lowercaseString];
							currentState = STATE_WAITING_FOR_EQUALS;
						}
						break;
					case STATE_WAITING_FOR_EQUALS:
						if( [token length] ) {
							if( [token isEqualToString:@"="] ) {
								currentState = STATE_WAITING_FOR_VALUE;
							}
							else {
								[parts addObject:attributeName];
								[baseEnvironment setObject:@"" forKey:attributeName];
								attributeName = [token lowercaseString];
								attributeValue = @"";
								currentState = STATE_WAITING_FOR_EQUALS;
							}
						}
						break;
					case STATE_WAITING_FOR_VALUE:
						attributeValue = token;
						[parts addObject:attributeName];
						[baseEnvironment setObject:attributeValue forKey:attributeName];
						attributeValue = @"";
						attributeName = @"";
						currentState = STATE_WAITING_FOR_NAME;
						break;
				}
			}
			
			if( [attributeName length] ) {
				[parts addObject:attributeName];
				[baseEnvironment setObject:attributeValue forKey:attributeName];
			}
			
			ParserLog(@"Parts: %@", parts);
			ParserLog(@"Base Environment: %@", baseEnvironment);
			
			[content deleteCharactersInRange:NSMakeRange(0, node.originalValue.length)];
			
			if( [[parts objectAtIndex:0] hasPrefix:tagBlockOpen] ) {
				if( [[parts objectAtIndex:0] isEqualToString:tagBlockOpen] ) {
					[parts removeObjectAtIndex:0];
				}
				else {
					[parts replaceObjectAtIndex:0 withObject:[[parts objectAtIndex:0] removePrefix:tagBlockOpen suffix:nil]];
				}
				
				node.type = TPNodeDefinition;
				
				[self parseContent:content parent:node];
			}
			else if( [[parts objectAtIndex:0] hasPrefix:tagBlockClose] ) {
				return YES;
			}
			else {
				node.type = TPNodeApplication;
			}
			
			node.name = [parts objectAtIndex:0];
			
			if( [parts count] > 1 ) {
				[node.values addObjectsFromArray:[parts subarrayWithRange:NSMakeRange(1, [parts count] - 1)]];
				
				for( NSString *key in node.values ) {
					[node.valuesMap setObject:[baseEnvironment objectForKey:key] forKey:key];
				}
			}
			
			[parent.childNodes addObject:node];

		}
		else {
			[NSException raise:@"TagParseError" format:@"Error parsing tag"];
		}
	}
	return NO;
}
@end
