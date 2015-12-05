//
//  main.m
//  OCDiscount
//
//  Created by Sumardi Shukor on 10/12/13.
//  Copyright (c) 2013 Software Machine Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCDiscount.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSString *markdown = nil;
        
        NSLog(@"HTML string => %@", [OCDiscount convertMarkdownString:markdown]);
    }
    return 0;
}

