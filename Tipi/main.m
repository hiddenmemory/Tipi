//
//  main.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Tipi.h"

int main(int argc, const char * argv[]) {

	@autoreleasepool {
		NSMutableDictionary *environment = [NSMutableDictionary dictionary];
		
		[environment setObject:[^NSString*( TPTemplateNode *node, NSMutableDictionary *environment ) {
			TPMarkdownDataParser *parser = [TPMarkdownDataParser parserForFile:[node.values objectAtIndex:0]];
			
			// Duplicate the environment for implementing the child nodes
			NSMutableDictionary *invokeEnvironment = [NSMutableDictionary dictionaryWithDictionary:environment];
			
			// Add the key-values from the data file
			[invokeEnvironment addEntriesFromDictionary:parser.values];
			
			return [node.childNodes tp_templateNodesExpandedUsingEnvironment:invokeEnvironment];
		} copy] forKey:@"include"];
		
		TPDataParser *p = [TPMarkdownDataParser parserForFile:@"/Users/chris/Repositories/git/hiddenMemory/Tipi/Tests/Test01.txt"];
		NSLog(@"p.values = %@", [p values]);
		
		TPTemplateParser *q = [TPTemplateParser parserForFile:@"/Users/chris/Repositories/git/hiddenMemory/Tipi/Tests/Test04.html"];
		NSLog(@"Expansion:\nSTART:\n%@:END", [q expansionUsingEnvironment:p.values]);
	}
    return 0;
}

