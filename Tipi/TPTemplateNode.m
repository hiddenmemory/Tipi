//
//  TPTemplateNode.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import "TPTemplateNode.h"
#import "NSString+Tipi.h"

@implementation TPTemplateNode
@synthesize type, originalValue, name, values, valuesMap, childNodes;

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
		valuesMap = [NSMutableDictionary dictionary];
		childNodes = [NSMutableArray array];
	}
	return self;
}
- (NSString*)descriptionWithDepth:(int)depth {
	NSMutableString *description = nil;
	
	if( self.type == TPNodeText ) {
		description = [NSMutableString stringWithFormat:@"%@<Text> '%@'\n", 
					   [NSString tp_stringByCreatingWhitespaceOfLength:depth],
					   [self.originalValue stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]];
	}
	else {
		description = [NSMutableString stringWithFormat:@"%@<Node> %@(%@)\n", 
					   [NSString tp_stringByCreatingWhitespaceOfLength:depth],
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
- (NSString*)expansionUsingEnvironment:(NSMutableDictionary*)environment {
	
	if( self.type == TPNodeText ) {
		return self.originalValue;
	}
	else {
		NSMutableString *expansion = [NSMutableString string];
		NSString *key = [self.name lowercaseString];
		
		if( [environment objectForKey:key] ) {
			id value = [environment objectForKey:key];
			
			if( [[value class] isSubclassOfClass:[NSString class]] ) {
				[expansion appendString:value];
			}
			else {
				NSString *(^expansionBlock)( TPTemplateNode *node, NSMutableDictionary *global ) = value;
				[expansion appendString:expansionBlock(self, environment)];
			}
		}
		else {
			for( TPTemplateNode *node in childNodes ) {
				[expansion appendString:[node expansionUsingEnvironment:environment]];
			}
		}
		return expansion;
	} 
}

@end
