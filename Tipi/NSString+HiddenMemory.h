//
//  NSString+HiddenMemory.h
// hiddenMemory Core Library
//
//  Created by Chris Ross on 03/06/2010.
//  Copyright 2010 hiddenMemory Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (HiddenMemory)

+ (NSString*)bytesToHuman:(size_t)value;

+ (NSString*)stringByTransformingToEmoji:(NSString*)_transform;
+ (NSDictionary*)emojiTransformMap;
+ (NSArray*)emojiTransformMapOrdered;

- (NSString *)stringByEncodingXMLEntities;

- (NSArray*)listOfURLS;
- (BOOL)isURL;

- (NSComparisonResult)emojiiLengthCompare:(NSString*)other;

- (NSString*)tagWithAttribute:(NSString*)key value:(NSString*)value content:(id(^)())content;
- (NSString*)tagWithAttributes:(NSDictionary*)values content:(id(^)())content;

- (NSString*)tagWithAttribute:(NSString*)key value:(NSString*)value body:(NSString*)content;
- (NSString*)tagWithAttributes:(NSDictionary*)values body:(NSString*)content;

- (NSString*)escapeHTML;
- (NSString*)stringByAddingHTMLFormattingToPlainCharacters;
- (NSString*)stringByUppercasingFirstCharacter;
- (NSString*)stringByExpandingTokensInDictionary:(NSDictionary*)tokens;

+ (NSString*)stringByExpandingFormat:(NSString*)format withTokens:(NSDictionary*)tokens;

+ (NSString*)stringByCreatingWhitespaceOfLength:(NSInteger)length;
- (NSString*)stringByTrimmingWhitespace;

- (NSString*)removePrefix:(NSString*)prefix suffix:(NSString*)suffix;

@end
