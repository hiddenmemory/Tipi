//
//  TPTemplateNode.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import "TPTemplateNode.h"
#import "NSString+HiddenMemory.h"

@implementation TPTemplateNode
@synthesize type, originalValue, name, values, childNodes;

+ (TPTemplateNode*)node{
	return [[TPTemplateNode alloc] init];
}
- (id)init {
	self = [super init];
	if( self ) {
		self.type = TPNodeUnknown;
		self.originalValue = @"";
		self.name = @"";
		values = [NSMutableArray array];
		childNodes = [NSMutableArray array];
	}
	return self;
}
- (NSString*)descriptionWithDepth:(int)depth {
	NSMutableString *description = nil;
	
	if( self.type == TPNodeText ) {
		description = [NSMutableString stringWithFormat:@"%@<Text> '%@'\n", 
					   [NSString stringByCreatingWhitespaceOfLength:depth],
					   [self.originalValue stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]];
	}
	else {
		description = [NSMutableString stringWithFormat:@"%@<Node> %@(%@)\n", 
					   [NSString stringByCreatingWhitespaceOfLength:depth],
					   self.name,
					   [values componentsJoinedByString:@", "]];
	}
	
	for( TPTemplateNode *node in childNodes ) {
		[description appendString:[node descriptionWithDepth:depth + 1]];
	}
	
	return description;
}
- (NSString*)description {
	return [self descriptionWithDepth:0];
}
- (NSString*)expansionUsingValues:(NSDictionary *)_values 
						   global:(NSMutableDictionary*)global 
{
	NSMutableString *expansion = [NSMutableString string];
	
	if( self.type == TPNodeText ) {
		[expansion appendString:self.originalValue];
	}
	else {
		NSString *key = [self.name lowercaseString];
		
		if( [global objectForKey:key] ) {
			NSString *(^expansionBlock)( TPTemplateNode *node, NSDictionary *values, NSMutableDictionary *global, NSArray *parameters ) = [global objectForKey:key];
			
			NSMutableArray *parameters = [NSMutableArray array];
			for( NSString *_valueName in self.values ) {
				NSString *valueName = [_valueName lowercaseString];
				
				NSString *(^valueExpansionBlock)( TPTemplateNode *node, NSDictionary *values, NSMutableDictionary *global, NSArray *parameters ) = [global objectForKey:valueName];
				if( valueExpansionBlock ) {
					[parameters addObject:valueExpansionBlock(self, _values, global, nil)];
				}
				else if( [_values objectForKey:valueName] ) {
					[parameters addObject:[_values objectForKey:valueName]];
				}
				else {
					[parameters addObject:_valueName];
				}
			}
			
			[expansion appendString:expansionBlock(self, _values, global, parameters)];
		}
		else if( [_values objectForKey:key] ) {
			[expansion appendString:[_values objectForKey:key]];
		}
		else {
			for( TPTemplateNode *node in childNodes ) {
				[expansion appendString:[node expansionUsingValues:_values global:global]];
			}
		}
	} 
	
	return expansion;
}

@end
