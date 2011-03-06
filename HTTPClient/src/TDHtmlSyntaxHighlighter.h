//
//  TDHtmlSyntaxHighlighter.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 8/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PKTokenizer;
@class PKToken;

@interface TDHtmlSyntaxHighlighter : NSObject {
    BOOL isDarkBG;
    BOOL inScript;
    PKTokenizer *tokenizer;
    NSMutableArray *stack;
    PKToken *ltToken;
    PKToken *gtToken;
    PKToken *startCommentToken;
    PKToken *endCommentToken;
    PKToken *startCDATAToken;
    PKToken *endCDATAToken;
    PKToken *startPIToken;
    PKToken *endPIToken;
    PKToken *startDoctypeToken;
    PKToken *fwdSlashToken;
    PKToken *eqToken;
    PKToken *scriptToken;
    PKToken *endScriptToken;
    
    NSMutableAttributedString *highlightedString;
    NSDictionary *headerNameAttributes;
    NSDictionary *headerValueAttributes;
    NSDictionary *textAttributes;
    NSDictionary *tagAttributes;
    NSDictionary *attrNameAttributes;
    NSDictionary *attrValueAttributes;
    NSDictionary *eqAttributes;
    NSDictionary *commentAttributes;
    NSDictionary *piAttributes;
}
- (id)initWithAttributesForDarkBackground:(BOOL)isDark;

- (NSAttributedString *)attributedStringForString:(NSString *)s;

@property (nonatomic, retain) NSMutableAttributedString *highlightedString;
@property (nonatomic, retain) NSDictionary *headerNameAttributes;
@property (nonatomic, retain) NSDictionary *headerValueAttributes;
@property (nonatomic, retain) NSDictionary *textAttributes;
@property (nonatomic, retain) NSDictionary *tagAttributes;
@property (nonatomic, retain) NSDictionary *attrNameAttributes;
@property (nonatomic, retain) NSDictionary *attrValueAttributes;
@property (nonatomic, retain) NSDictionary *eqAttributes;
@property (nonatomic, retain) NSDictionary *commentAttributes;
@property (nonatomic, retain) NSDictionary *piAttributes;
@end
