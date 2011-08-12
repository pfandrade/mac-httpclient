//
//  HCWindowController.h
//  HTTPClient
//
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol HTTPService;
@class TDSourceCodeTextView;
@class TDHtmlSyntaxHighlighter;

@interface HCWindowController : NSWindowController <NSComboBoxCellDataSource> {
    NSComboBox *URLComboBox;
    NSComboBox *methodComboBox;
    NSTableView *headersTable;
    NSTextView *bodyTextView;
    NSTabView *tabView;
    TDSourceCodeTextView *requestTextView;
    TDSourceCodeTextView *responseTextView;
    NSScrollView *requestScrollView;
    NSScrollView *responseScrollView;
    NSArrayController *headersController;

    id <HTTPService>service;
    
    NSMutableDictionary *command;
    NSAttributedString *highlightedRawRequest;
    NSAttributedString *highlightedRawResponse;
    BOOL busy;
    BOOL bodyShown;
    
    NSArray *methods;
    NSArray *headerNames;
    NSDictionary *headerValues;

    BOOL multipartBodyShown;
    NSString *attachedFilePath;
    NSString *attachedFilename;
    
    TDHtmlSyntaxHighlighter *syntaxHighlighter;
    
    // HTTPAuth
    NSPanel *httpAuthSheet;
    NSTextField *authMessageTextField;
    NSTextField *authUsernameTextField;
    NSTextField *authPasswordTextField;
    
    NSString *authUsername;
    NSString *authPassword;
    NSString *authMessage;
    BOOL rememberAuthPassword;    
}
- (IBAction)openLocation:(id)sender;
- (IBAction)historyMenuItemAction:(id)sender;
- (IBAction)execute:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)showRequest:(id)sender;
- (IBAction)showResponse:(id)sender;
//- (IBAction)showMultipartBodyView:(id)sender;
- (IBAction)showNormalBodyView:(id)sender;
- (IBAction)runAttachFileSheet:(id)sender;

@property (nonatomic, retain) IBOutlet NSComboBox *URLComboBox;
@property (nonatomic, retain) IBOutlet NSComboBox *methodComboBox;
@property (nonatomic, retain) IBOutlet NSTableView *headersTable;
@property (nonatomic, retain) IBOutlet NSTextView *bodyTextView;
@property (nonatomic, retain) IBOutlet NSTabView *tabView;
@property (nonatomic, retain) IBOutlet TDSourceCodeTextView *requestTextView;
@property (nonatomic, retain) IBOutlet TDSourceCodeTextView *responseTextView;
@property (nonatomic, retain) IBOutlet NSScrollView *requestScrollView;
@property (nonatomic, retain) IBOutlet NSScrollView *responseScrollView;
@property (nonatomic, retain) IBOutlet NSArrayController *headersController;

@property (nonatomic, retain) id <HTTPService>service;

@property (nonatomic, retain) id command;
@property (nonatomic, copy) NSAttributedString *highlightedRawRequest;
@property (nonatomic, copy) NSAttributedString *highlightedRawResponse;

@property (nonatomic, getter=isBusy) BOOL busy;
@property (nonatomic, getter=isBodyShown) BOOL bodyShown;

@property (nonatomic, retain) NSArray *methods;
@property (nonatomic, retain) NSArray *headerNames;
@property (nonatomic, retain) NSDictionary *headerValues;

@property (nonatomic, getter=isMultipartBodyShown) BOOL multipartBodyShown;
@property (nonatomic, retain) NSString *attachedFilePath;
@property (nonatomic, retain) NSString *attachedFilename;

@property (nonatomic, retain) TDHtmlSyntaxHighlighter *syntaxHighlighter;

@property (nonatomic, retain) IBOutlet NSPanel *httpAuthSheet;
@property (nonatomic, retain) IBOutlet NSTextField *authMessageTextField;
@property (nonatomic, retain) IBOutlet NSTextField *authUsernameTextField;
@property (nonatomic, retain) IBOutlet NSTextField *authPasswordTextField;

@property (nonatomic, retain) NSString *authUsername;
@property (nonatomic, retain) NSString *authPassword;
@property (nonatomic, retain) NSString *authMessage;
@property (nonatomic) BOOL rememberAuthPassword;
@end