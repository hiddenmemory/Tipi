//
//  NSArray+Tipi.m
//  Tipi
//
//  Created by Chris Ross on 07/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import "NSArray+Tipi.h"
#import "Tipi.h"

@implementation NSArray (Tipi)

- (NSString*)tp_templateNodesExpandedUsingEnvironment:(NSMutableDictionary*)environment {
	NSMutableString *expansion = [NSMutableString string];
	
	for( TPTemplateNode *childNode in self ) {
		[expansion appendString:[childNode expansionUsingEnvironment:environment]];
	}
	
	return expansion;
}

@end
