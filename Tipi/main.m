//
//  main.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TPParser.h"
#import "TPMarkdownDataParser.h"

int main(int argc, const char * argv[]) {

	@autoreleasepool {
		TPParser *p = [TPMarkdownDataParser parserForFile:@"/Users/chris/Repositories/git/hiddenMemory/Tipi/Tests/Test01.txt"];
		NSLog(@"p.values = %@", [p values]);
	}
    return 0;
}

