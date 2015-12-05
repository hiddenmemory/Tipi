//
//  TPTemplateParser.h
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPTemplateNode;

@interface TPTemplateParser : NSObject
@property (readonly) TPTemplateNode *root;
@property (readonly) NSString *sourcePath;

@property (strong) NSString *tagStart;
@property (strong) NSString *tagBlockOpen;
@property (strong) NSString *tagBlockClose;
@property (strong) NSString *tagEnd;

- (instancetype)initWithString:(NSString *)_content;

+ (TPTemplateParser*)parserForFile:(NSString*)path;

- (NSString*)expansion;
- (NSString*)expansionUsingEnvironment:(NSDictionary*)values;
- (NSString*)expansionUsingImportEnvironment:(NSDictionary*)values;

- (NSString*)locateImport:(NSString*)name;

@end
