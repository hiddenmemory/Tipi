//
//  main.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TPDataParser.h"
#import "TPMarkdownDataParser.h"
#import "TPTemplateParser.h"

int main(int argc, const char * argv[]) {

	@autoreleasepool {
		TPDataParser *p = [TPMarkdownDataParser parserForFile:@"/Users/chris/Repositories/git/hiddenMemory/Tipi/Tests/Test01.txt"];
		NSLog(@"p.values = %@", [p values]);
		
		TPTemplateParser *q = [TPTemplateParser parserForFile:@"/Users/chris/Repositories/git/hiddenMemory/Tipi/Tests/Test03.html"];
		NSLog(@"Expansion: %@", [q expansionUsingEnvironment:p.values]);
	}
    return 0;
}

