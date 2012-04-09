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
		
		for( int i = 1; i <= 6; i++ ) {
			NSString *inputPath = [NSString stringWithFormat:@"/Users/chris/Repositories/git/hiddenMemory/Tipi/Tests/basic/Test0%d.input", i];
			NSString *outputPath = [NSString stringWithFormat:@"/Users/chris/Repositories/git/hiddenMemory/Tipi/Tests/basic/Test0%d.output", i];
			
			TPTemplateParser *q = [TPTemplateParser parserForFile:inputPath];
			NSString *expansion = [q expansionUsingEnvironment:[NSDictionary dictionary]];
								   
			if( [[NSFileManager defaultManager] fileExistsAtPath:outputPath] ) {
				NSString *goldenExpansion = [NSString stringWithContentsOfFile:outputPath
																	  encoding:NSUTF8StringEncoding
																		 error:nil];
				
				if( [goldenExpansion isEqualToString:expansion] ) {
					NSLog(@"Test %d passed", i);
				}
				else {
					NSLog(@">>>> Test %d failed <<<<", i);
				}
			}
			else {
				NSLog(@"Expansion:\nSTART:\n%@:END", expansion);
				[expansion writeToFile:outputPath
							atomically:NO
							  encoding:NSUTF8StringEncoding
								 error:nil];
			}
		}
	}
    return 0;
}

