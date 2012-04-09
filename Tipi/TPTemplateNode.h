//
//  TPTemplateNode.h
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	TPNodeUnknown,
	TPNodeText,
	TPNodeDefinition,
	TPNodeApplication
} TPNodeType;

@interface TPTemplateNode : NSObject
@property (assign)   TPNodeType type;
@property (strong)   NSString *originalValue;
@property (strong)   NSString *name;
@property (readonly) NSMutableArray *values;
@property (readonly) NSMutableDictionary *valuesMap;
@property (readonly) NSMutableArray *childNodes;

+ (TPTemplateNode*)node;
- (NSString*)expansionUsingEnvironment:(NSMutableDictionary*)environment;
@end
