//
//  NSString+Tipi.h
//  Tipi Core Library
//
//  Created by Chris Ross on 03/06/2010.
//  Copyright 2010 hiddenMemory Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Tipi)

- (NSString *)tp_stringByEncodingXMLEntities;

- (NSArray*)tp_listOfURLS;
- (BOOL)tp_isURL;

- (NSString*)tp_tagWithAttribute:(NSString*)key value:(NSString*)value content:(id(^)())content;
- (NSString*)tp_tagWithAttributes:(NSDictionary*)values content:(id(^)())content;

- (NSString*)tp_tagWithAttribute:(NSString*)key value:(NSString*)value body:(NSString*)content;
- (NSString*)tp_tagWithAttributes:(NSDictionary*)values body:(NSString*)content;

- (NSString*)tp_escapeHTML;
- (NSString*)tp_stringByAddingHTMLFormattingToPlainCharacters;
- (NSString*)tp_stringByUppercasingFirstCharacter;
- (NSString*)tp_stringByExpandingTokensInDictionary:(NSDictionary*)tokens;

+ (NSString*)tp_stringByExpandingFormat:(NSString*)format withTokens:(NSDictionary*)tokens;

+ (NSString*)tp_stringByCreatingWhitespaceOfLength:(NSInteger)length;
- (NSString*)tp_stringByTrimmingWhitespace;

- (NSString*)tp_stringByRemovingPrefix:(NSString*)prefix suffix:(NSString*)suffix;

@end
