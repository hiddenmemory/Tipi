//
//  TPTemplateParser.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import "TPTemplateParser.h"
#import "TPTemplateNode.h"

#import "NSString+Tipi.h"
#import "NSArray+Tipi.h"
#import "TPBlockWrapper.h"

#define ParserLog if( NO ) NSLog
//#define ParserLog NSLog

@interface TPTemplateParser () {
    TPTemplateNode *root;

    NSString *tagStart, *tagEnd;
    NSString *tagBlockOpen, *tagBlockClose;

    NSString *sourcePath;
}
- (id)initWithFileAtPath:(NSString*)path;
- (void)parseContent:(NSMutableString*)content parent:(TPTemplateNode*)parent;
- (BOOL)parseTag:(NSMutableString*)content parent:(TPTemplateNode*)parent;
@end

@implementation TPTemplateParser
@synthesize root, sourcePath;
@synthesize tagStart, tagEnd, tagBlockOpen, tagBlockClose;

+ (TPTemplateParser*)parserForFile:(NSString*)path {
    if( path ) {
        return [[[self class] alloc] initWithFileAtPath:path];
    }
    return nil;
}
- (instancetype)initWithFileAtPath:(NSString*)path {
    self = [self initWithString:[NSString stringWithContentsOfFile:path
                                                                 encoding:NSUTF8StringEncoding
                                                                    error:nil]];
    if( self ) {
        sourcePath = [path stringByDeletingLastPathComponent];
    }
    return self;
}
- (instancetype)initWithString:(NSString*)_content {
    self = [super init];
    if( self ) {
        root = [TPTemplateNode node];

        tagStart = @"{{";
        tagBlockOpen = @"#";
        tagBlockClose = @"/";
        tagEnd = @"}}";

        NSMutableString *content = [_content mutableCopy];

        [self parseContent:content parent:root];

        ParserLog(@"Node: %@", [root description]);
    }
    return self;
}
- (id)expandValue:(id)value environment:(NSMutableDictionary*)currentEnvironment node:(TPTemplateNode*)currentNode {
    ParserLog(@"Looking to expand value: '%@'", value);

    if( [[value class] isSubclassOfClass:[NSString class]] && [value rangeOfString:@" "].location == NSNotFound ) {
        if( currentEnvironment[[value lowercaseString]] ) {
            value = currentEnvironment[[value lowercaseString]];
        }
    }

    if( value == nil ) {
        value = @"";
    }

    return value;
}
- (NSString*)locateImport:(NSString*)name {
    return [NSString stringWithFormat:@"%@/%@", sourcePath, name];
}
- (NSString*)expansionUsingImportEnvironment:(NSDictionary*)values {
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithDictionary:(values ? values : [NSDictionary dictionary])];

    id importBlock = ^NSString*( TPTemplateNode *node, NSMutableDictionary *environment ) {
        NSString *importPath = [self locateImport:[node.valuesMap objectForKey:@"source"]];

        if( [[NSFileManager defaultManager] fileExistsAtPath:importPath] ) {
            NSLog(@"Importing: %@", importPath);
            TPTemplateParser *importParser = [TPTemplateParser parserForFile:importPath];
            return [importParser.root expansionUsingEnvironment:environment];
        }

        return @"";
    };

    [environment setObject:[importBlock copy] forKey:@"import"];

    return [self expansionUsingEnvironment:environment];
}
- (NSString*)expansionUsingEnvironment:(NSDictionary*)values {
    NSMutableDictionary *environment = [NSMutableDictionary dictionary];

    for( NSString *key in [values allKeys] ) {
        environment[key.lowercaseString] = values[key];
    }

    environment[@"bind"] = @"";

    environment[@"def"] = [TPBlockWrapper wrap:^NSString*( TPTemplateNode *node, NSMutableDictionary *environment ) {
        if( [node.values count] ) {
            NSString *key = [node.values.firstObject lowercaseString];
            if( !([key isEqualToString:@"bind"] || [key isEqualToString:@"def"]) ) {
                // Don't allow people to redfine bind or def.
                if( [node.childNodes count] ) {
                    // If there is one or more child nodes, we assume that this is an expansion block
                    NSMutableDictionary *capturedEnvironment = [NSMutableDictionary dictionaryWithDictionary:environment];

                    environment[key] = [TPBlockWrapper wrap:^NSString*( TPTemplateNode *currentNode, NSMutableDictionary *currentEnvironment ) {
                        NSMutableDictionary *invokeEnvironment = [NSMutableDictionary dictionaryWithDictionary:capturedEnvironment];

                        ParserLog(@"Processing node %@", currentNode.name);

                        // Capture {{this}}
                        invokeEnvironment[@"this"] = [currentNode.childNodes tp_templateNodesExpandedUsingEnvironment:currentEnvironment];

                        // Capture each parameter: this maps the {{def NAME KEY1=PARAM1}} -> value provided in parameters
                        [[node.values subarrayWithRange:NSMakeRange(1, [node.values count] - 1)] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSString *key = [obj lowercaseString];
                            id value = nil;

                            ParserLog(@"Checking key: %@", key);

                            if( currentNode.valuesMap[key] ) {
                                value = currentNode.valuesMap[key];
                                ParserLog(@"Fetching value %@ from current node", value);
                            }
                            else if( node.valuesMap[key] ) {
                                value = node.valuesMap[key];
                                ParserLog(@"Fetching value %@ from def node", value);
                            }
                            else {
                                value = key;
                                ParserLog(@"Unable to find value, using key name %@", value);
                            }

                            invokeEnvironment[key] = [self expandValue:value
                                                           environment:currentEnvironment
                                                                  node:currentNode];
                        }];

                        // This walks the node on which the def is being invoked to see if there are any bind commands
                        for( TPTemplateNode *bindNode in currentNode.childNodes ) {
                            if( [bindNode.name isEqualToString:@"bind"] ) {
                                if( [bindNode.childNodes count] ) {
                                    // If we have children, build a block that will evaluate those
                                    if( node.valuesMap[bindNode.values.firstObject] ) {
                                        id block = ^NSString*( TPTemplateNode *currentNode, NSMutableDictionary *currentEnvironment ) {
                                            return [bindNode.childNodes tp_templateNodesExpandedUsingEnvironment:currentEnvironment];
                                        };
                                        invokeEnvironment[[bindNode.values.firstObject lowercaseString]] = [block copy];
                                    }
                                }
                                else if( [bindNode.values count] > 0 ) {
                                    // Otherwise, go through the key/value pairing
                                    for( NSString *key in bindNode.values ) {
                                        if( node.valuesMap[key] ) {
                                            ParserLog(@"Binding key %@", key);
                                            invokeEnvironment[[key lowercaseString]] = [self expandValue:bindNode.valuesMap[key]
                                                                                             environment:currentEnvironment
                                                                                                    node:currentNode];
                                        }
                                        else {
                                            ParserLog(@"Ignoring key %@", key);
                                        }
                                    }
                                }
                            }
                        }

                        ParserLog(@"Invoke environment: %@ (%@)", invokeEnvironment, currentNode);

                        // Expand and return the result
                        NSString *expansion = [node.childNodes tp_templateNodesExpandedUsingEnvironment:invokeEnvironment];
                        ParserLog(@"Expansion for %@ = %@", currentNode.name, expansion);
                        return expansion;
                    }];
                }
                else {
                    /// If there are no child nodes, we set a value in the environment
                    for( NSString *subkey in node.values ) {
                        environment[subkey] = [self expandValue:node.valuesMap[subkey]
                                                    environment:environment
                                                           node:node];
                    }

                    ParserLog(@"Environment: %@", environment);
                }
            }
        }

        return @"";
    }];

    return [root expansionUsingEnvironment:environment];
}
- (NSString*)expansion {
    return [self expansionUsingEnvironment:[NSDictionary dictionary]];
}
- (void)parseContent:(NSMutableString*)content parent:(TPTemplateNode*)parent {
    while( [content length] ) {
        NSRange range = [content rangeOfString:tagStart];
        BOOL shouldParseTag = YES;

        if( range.location == NSNotFound ) {
            range.location = [content length];
            shouldParseTag = NO;
        }

        TPTemplateNode *node = [TPTemplateNode node];
        node.type = TPNodeText;
        node.name = @"";
        node.originalValue = [content substringToIndex:range.location];
        [node.values addObject:node.originalValue];
        [parent.childNodes addObject:node];

        [content deleteCharactersInRange:NSMakeRange(0, range.location)];

        if( shouldParseTag ) {
            if( [self parseTag:content parent:parent] ) {
                return;
            }
        }
    }
}

- (NSString*)nextToken:(NSMutableString*)stream {
    NSString *nextToken = @"";

    NSString *stringToParse = [stream tp_stringByTrimmingWhitespace];

    if( [stringToParse hasPrefix:@"\""] || [stringToParse hasPrefix:@"'"] ) {
        // If we match a comment character, match until the next non-escaped version, otherwise until end of the string
        unichar matchCharacter = [stringToParse characterAtIndex:0];
        BOOL success = NO;

        for( NSUInteger i = 1; i < [stringToParse length]; i++ ) {
            unichar c = [stringToParse characterAtIndex:i];
            if( c == matchCharacter && [stringToParse characterAtIndex:i - 1] != '\\' ) {
                nextToken = [stringToParse substringWithRange:NSMakeRange(1, i - 1)];
                stringToParse = [stringToParse substringFromIndex:i + 1];
                success = YES;
                break;
            }
        }

        if( !success ) {
            nextToken = stringToParse;
            stringToParse = @"";
        }
    }
    else if( [stringToParse hasPrefix:@"="] ) {
        stringToParse = [stringToParse substringFromIndex:1];
        nextToken = @"=";
    }
    else {
        // Chomp until the next space
        NSRange range = [stringToParse rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@" \t="]];

        nextToken = (range.location == NSNotFound ? stringToParse : [stringToParse substringToIndex:range.location]);

        if( range.location != NSNotFound ) {
            stringToParse = [stringToParse substringFromIndex:[nextToken length]];
        }
        else {
            stringToParse = @"";
        }
    }

    [stream setString:stringToParse];

    return nextToken;
}

- (BOOL)parseTag:(NSMutableString*)content parent:(TPTemplateNode*)parent {
    if( [content hasPrefix:tagStart] ) {
        NSRange tagContentRange = [content rangeOfString:tagEnd];

        if( tagContentRange.location != NSNotFound ) {
            TPTemplateNode *node = [TPTemplateNode node];
            node.originalValue = [content substringToIndex:tagContentRange.location + tagEnd.length];

            NSMutableArray *parts = [NSMutableArray array];
            NSMutableString *stringToParse = [NSMutableString stringWithString:[node.originalValue tp_stringByRemovingPrefix:tagStart suffix:tagEnd]];

#define STATE_WAITING_FOR_NAME   0
#define STATE_WAITING_FOR_EQUALS 1
#define STATE_WAITING_FOR_VALUE  2

            NSMutableDictionary *baseEnvironment = [NSMutableDictionary dictionary];

            NSString *attributeName = @"";
            NSString *attributeValue = @"";
            int       currentState = STATE_WAITING_FOR_NAME;

            while( [stringToParse length] ) {
                NSString *token = [self nextToken:stringToParse];

                switch( currentState ) {
                    case STATE_WAITING_FOR_NAME:
                        if( [token length] ) {
                            attributeName = [token lowercaseString];
                            currentState = STATE_WAITING_FOR_EQUALS;
                        }
                        break;
                    case STATE_WAITING_FOR_EQUALS:
                        if( [token length] ) {
                            if( [token isEqualToString:@"="] ) {
                                currentState = STATE_WAITING_FOR_VALUE;
                            }
                            else {
                                [parts addObject:attributeName];
                                baseEnvironment[attributeName] = @"";
                                attributeName = [token lowercaseString];
                                attributeValue = @"";
                                currentState = STATE_WAITING_FOR_EQUALS;
                            }
                        }
                        break;
                    case STATE_WAITING_FOR_VALUE:
                        attributeValue = token;
                        [parts addObject:attributeName];
                        baseEnvironment[attributeName] = attributeValue;
                        attributeValue = @"";
                        attributeName = @"";
                        currentState = STATE_WAITING_FOR_NAME;
                        break;
                }
            }

            if( [attributeName length] ) {
                [parts addObject:attributeName];
                baseEnvironment[attributeName] = attributeValue;
            }

            ParserLog(@"Parts: %@", parts);
            ParserLog(@"Base Environment: %@", baseEnvironment);

            [content deleteCharactersInRange:NSMakeRange(0, node.originalValue.length)];

            if( [parts.firstObject hasPrefix:tagBlockOpen] ) {
                if( [parts.firstObject isEqualToString:tagBlockOpen] ) {
                    [parts removeObjectAtIndex:0];
                }
                else {
                    parts[0] = [parts.firstObject tp_stringByRemovingPrefix:tagBlockOpen suffix:nil];
                }

                node.type = TPNodeDefinition;

                [self parseContent:content parent:node];
            }
            else if( [parts.firstObject hasPrefix:tagBlockClose] ) {
                return YES;
            }
            else {
                node.type = TPNodeApplication;
            }

            node.name = parts.firstObject;

            if( [parts count] > 1 ) {
                [node.values addObjectsFromArray:[parts subarrayWithRange:NSMakeRange(1, [parts count] - 1)]];

                for( NSString *key in node.values ) {
                    node.valuesMap[key] = baseEnvironment[key];
                }
            }

            [parent.childNodes addObject:node];

            node.parent = parent;
        }
        else {
            [NSException raise:@"TagParseError" format:@"Error parsing tag"];
        }
    }
    return NO;
}
@end
