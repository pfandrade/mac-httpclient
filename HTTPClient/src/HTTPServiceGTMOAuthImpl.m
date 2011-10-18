//
//  HTTPServiceGTMOAuthImpl.m
//  HTTPClient
//
//  Created by Paulo Andrade on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPServiceGTMOAuthImpl.h"
#import <GTMOAuth/GTMHTTPFetcher.h>


CFHTTPMessageRef HTTPMessageCreateForRequest(NSURLRequest *request) {
    NSCParameterAssert([request HTTPBodyStream] == nil);
    
    CFHTTPMessageRef message = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)[request HTTPMethod], (CFURLRef)[request URL], kCFHTTPVersion1_1);
    
    for (NSString *currentHeader in [request allHTTPHeaderFields]) {
        CFHTTPMessageSetHeaderFieldValue(message, (CFStringRef)currentHeader, (CFStringRef)[[request allHTTPHeaderFields] objectForKey:currentHeader]);
    }
    
    if ([request HTTPBody] != nil) {
        CFHTTPMessageSetBody(message, (CFDataRef)[request HTTPBody]);
    }
    
    return message;
}

CFHTTPMessageRef HTTPMessageCreateForResponse(NSHTTPURLResponse *response, NSData *body) {
    CFHTTPMessageRef message = CFHTTPMessageCreateResponse(kCFAllocatorDefault, [response statusCode], (CFStringRef)[NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]], kCFHTTPVersion1_1);
    [[response allHeaderFields] enumerateKeysAndObjectsUsingBlock:^ (id key, id obj, BOOL *stop) {
        CFHTTPMessageSetHeaderFieldValue(message, (CFStringRef)key, (CFStringRef)obj);
    }];
    CFHTTPMessageSetBody(message, (CFDataRef)body);
    return message;
}


@interface GTMHTTPFetcher (Protected)
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

- (void)authorizeRequest;
@end

@interface MyFetcher : GTMHTTPFetcher {
@private
    BOOL followRedirects_;
}
@property (nonatomic, assign) BOOL followRedirects;
@end


@implementation MyFetcher

@synthesize followRedirects = followRedirects_;

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)redirectRequest
            redirectResponse:(NSURLResponse *)redirectResponse {
    if(self.followRedirects){
        NSURLRequest *request = [super connection:connection 
                                  willSendRequest:redirectRequest 
                                 redirectResponse:redirectResponse];
        if(redirectResponse != nil){
             [(GTMOAuthAuthentication *)self.authorizer authorizeRequest:self.mutableRequest];
            request = self.mutableRequest;
        }
        return request;
    } else {
        if(redirectResponse != nil){
            [connection cancel];
            [self connection:connection didReceiveResponse:redirectResponse];
            [self connectionDidFinishLoading:connection];
        }
        return redirectRequest;
    }
}

@end
@interface HTTPServiceGTMOAuthImpl () 

- (NSString *)rawStringForHTTPMessage:(CFHTTPMessageRef)message;
- (NSStringEncoding)stringEncodingForBodyOfHTTPMessage:(CFHTTPMessageRef)message;

@end


@implementation HTTPServiceGTMOAuthImpl

@synthesize auth = auth_;
@synthesize delegate = delegate_;

- (void)dealloc {
    [auth_ release];
    [super dealloc];
}

#pragma mark HTTPService methods
- (id)initWithDelegate:(id)d
{
    self = [super init];
    if(self){
        delegate_ = d;
    }
    return self;
}

- (void)sendHTTPRequest:(id)cmd
{
    NSString *URLString = [[cmd objectForKey:@"URLString"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSString *method = [cmd objectForKey:@"method"];
    NSString *body = [cmd objectForKey:@"body"];
    NSArray *headers = [cmd objectForKey:@"headers"];

    //    BOOL followRedirects = [[cmd objectForKey:@"followRedirects"] boolValue];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:[method uppercaseString]];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    for (id header in headers) {
        NSString *name = [header objectForKey:@"name"];
        NSString *value = [header objectForKey:@"value"];
        if ([name length] && [value length]) {
            [request addValue:value forHTTPHeaderField:name];
        }
    }

    MyFetcher *fetcher = (MyFetcher *)[MyFetcher fetcherWithRequest:request];
    fetcher.followRedirects = [[cmd valueForKey:@"followRedirects"] boolValue];
    if(self.auth != nil && [self.auth canAuthorize]){
        fetcher.authorizer = self.auth;
    }
    
    fetcher.userData = cmd;
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(fetcher:finishedWithData:error:)];
}

- (void)fetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error
{
    NSMutableDictionary *command = fetcher.userData;
    CFHTTPMessageRef requestMessage = HTTPMessageCreateForRequest(fetcher.mutableRequest);
    CFHTTPMessageRef responseMessage = HTTPMessageCreateForResponse((NSHTTPURLResponse*)fetcher.response, retrievedData);

    NSString *finalURLString = [(NSURL *)CFHTTPMessageCopyRequestURL(requestMessage) absoluteString];
    NSString *rawRequest = [self rawStringForHTTPMessage:requestMessage];
    NSString *rawResponse = [self rawStringForHTTPMessage:responseMessage];

    [command setObject:finalURLString forKey:@"finalURLString"];
    [command setObject:finalURLString forKey:@"URLString"];
    [command setObject:rawRequest forKey:@"rawRequest"];
    [command setObject:rawResponse forKey:@"rawResponse"];
    
    CFRelease(requestMessage);
    CFRelease(responseMessage);
    
    if(error == nil && [rawResponse length] > 0){
        [self.delegate HTTPService:self didRecieveResponse:rawResponse forRequest:command];
    } 
    else {
        if(!rawResponse.length){
            NSString *s = @"(( Zero-length response returned from server. ))";
            [command setObject:s forKey:@"rawResponse"];
            [self.delegate HTTPService:self request:fetcher.userData didFail:s];
        } else {
            [self.delegate HTTPService:self request:fetcher.userData didFail:[error localizedDescription]];
        }
    }
}

#pragma mark Private

- (NSString *)rawStringForHTTPMessage:(CFHTTPMessageRef)message {
    
    // ok so this is weird. we're using the declared content-type string encoding on the entire raw messaage. 
    // dunno if that makes sense
    NSStringEncoding encoding = [self stringEncodingForBodyOfHTTPMessage:message];
    NSData *data = (NSData *)CFHTTPMessageCopySerializedMessage(message);
    NSString *result = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
    
    // if the result is nil, give it one last try with utf8 or preferrably latin1. 
    // ive seen this work for servers that lie (sideways glance at reddit.com)
    if (!result) {
        if (NSISOLatin1StringEncoding == encoding) {
            encoding = NSUTF8StringEncoding;
        } else {
            encoding = NSISOLatin1StringEncoding;
        }
        result = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
    }
    [data release];
    return result;
}


- (NSStringEncoding)stringEncodingForBodyOfHTTPMessage:(CFHTTPMessageRef)message {
    
    // use latin1 as the default. why not.
    NSStringEncoding encoding = NSISOLatin1StringEncoding;
    
    // get the content-type header field value
    NSString *contentType = [(id)CFHTTPMessageCopyHeaderFieldValue(message, (CFStringRef)@"Content-Type") autorelease];
    if (contentType) {
        
        // "text/html; charset=utf-8" is common, so just get the good stuff
        NSRange r = [contentType rangeOfString:@"charset="];
        if (NSNotFound == r.location) {
            r = [contentType rangeOfString:@"="];
        }
        if (NSNotFound != r.location) {
            contentType = [contentType substringFromIndex:r.location + r.length];
        }
        
        // trim whitespace
        contentType = [contentType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // convert to an NSStringEncoding
        CFStringEncoding cfStrEnc = CFStringConvertIANACharSetNameToEncoding((CFStringRef)contentType);
        if (kCFStringEncodingInvalidId != cfStrEnc) {
            encoding = CFStringConvertEncodingToNSStringEncoding(cfStrEnc);
        }
    }
    
    return encoding;
}


@end
