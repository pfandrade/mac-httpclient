//
//  HTTPServiceGTMOAuthImpl.h
//  HTTPClient
//
//  Created by Paulo Andrade on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPService.h"
#import <GTMOAuth/GTMOAuthAuthentication.h>

@interface HTTPServiceGTMOAuthImpl : NSObject <HTTPService>
{
    GTMOAuthAuthentication *auth_;
    id delegate_;
}
@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) GTMOAuthAuthentication *auth;

@end
