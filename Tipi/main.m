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
		if( argc > 1 ) {
			NSString *path = [NSString stringWithFormat:@"%s/Tests/", argv[1]];
			
			NSLog(@"Scanning %@ for test suites...", path);
			
			[[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil] enumerateObjectsUsingBlock:^(NSString *suiteName, NSUInteger idx, BOOL *stop) {
				BOOL isDirectory = NO;
				NSString *testPath = [NSString stringWithFormat:@"%@%@/", path, suiteName];
				
				if( [[NSFileManager defaultManager] fileExistsAtPath:testPath isDirectory:&isDirectory] && isDirectory ) {
					NSLog(@"Test suite: %@ (path: %@)", suiteName, testPath);
					
					[[[NSFileManager defaultManager] contentsOfDirectoryAtPath:testPath error:nil] enumerateObjectsUsingBlock:^(NSString *item, NSUInteger idx, BOOL *stop) {
						if( [item hasSuffix:@".input"] ) {
							NSString *inputPath = [NSString stringWithFormat:@"%@%@", testPath, item];
							NSString *outputPath = [NSString stringWithFormat:@"%@%@", testPath, [item stringByReplacingOccurrencesOfString:@".input"
																																 withString:@".output"]];
							
							TPTemplateParser *q = [TPTemplateParser parserForFile:inputPath];
							NSString *expansion = [q expansionUsingEnvironment:[NSDictionary dictionary]];
							
							if( [[NSFileManager defaultManager] fileExistsAtPath:outputPath] ) {
								NSString *goldenExpansion = [NSString stringWithContentsOfFile:outputPath
																					  encoding:NSUTF8StringEncoding
																						 error:nil];
								
								if( [goldenExpansion isEqualToString:expansion] ) {
									NSLog(@"[%@] Test Passed", item);
								}
								else {
									NSLog(@"[%@] >>>> Test failed <<<<", item);
								}
							}
							else {
								NSLog(@"[%@] Creating new test output:\n%@", item, expansion);
								[expansion writeToFile:outputPath
											atomically:NO
											  encoding:NSUTF8StringEncoding
												 error:nil];
							}
						}
					}];
				}
			}];
		}
		else {
			NSLog(@"Please provide a path to the Tipi test suite");
		}
	}
    return 0;
}

