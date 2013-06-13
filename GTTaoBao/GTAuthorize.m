//
//  GTAuthorize.m
//  PocoCamera2
//
//  Created by GTL on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTAuthorize.h"

@implementation GTAuthorize
@synthesize appKey;
@synthesize appSecret;
@synthesize request;
@synthesize delegate;

#pragma mark LifeCircle
- (id)init {
    if ([super init]) {
        [self initWithAppKey:kGTAppKey appSecret:kGTAppSecret];
    }
    return self;
}

- (void)dealloc {
    [appKey release], appKey = nil;
    [appSecret release], appSecret = nil;
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;
    delegate = nil;
    [super dealloc];
}

#pragma mark -
- (NSString *)getValueStringFromUrl:(NSString *)url forParam:(NSString *)param {
    NSString * str = nil;
    NSRange start = [url rangeOfString:[param stringByAppendingString:@"="]];
    if (start.location != NSNotFound) {
        NSRange end = [[url substringFromIndex:start.location + start.length] rangeOfString:@"&"];
        NSUInteger offset = start.location+start.length;
        str = end.location == NSNotFound
        ? [url substringFromIndex:offset]
        : [url substringWithRange:NSMakeRange(offset, end.location)];
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return str;
}

#pragma mark Public Methods
- (void)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret {
    self.appKey = theAppKey;
    self.appSecret = theAppSecret;
}

- (void)startAuthorize {
//    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//	NSArray* graphCookies = [cookies cookiesForURL:
//                             [NSURL URLWithString:@"http://graph.renren.com"]];
//	for (NSHTTPCookie* cookie in graphCookies) {
//		[cookies deleteCookie:cookie];
//	}
//	NSArray* widgetCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://widget.renren.com"]];
//	for (NSHTTPCookie* cookie in widgetCookies) {
//		[cookies deleteCookie:cookie];
//	}
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:appKey forKey:@"client_id"];
    [parameters setValue:kCallbackURL forKey:@"redirect_uri"];
    [parameters setValue:@"code" forKey:@"response_type"];
    [parameters setValue:@"wap" forKey:@"view"];
    NSArray *permissions = [NSArray arrayWithObjects:@"item",@"promotion",@"usergrade",nil];
    NSString *permissionScope = [permissions componentsJoinedByString:@","];
    [parameters setValue:permissionScope forKey:@"scope"];
    
    NSString *urlString = [GTRequest serializeURL:kGTAuthorizeURL
                                           params:parameters
                                       httpMethod:@"GET"];
    
    NSLog(@"urlString:%@", urlString);
    GTLoginView *loginView = [[GTLoginView alloc] init];
    [loginView setDelegate:self];
    [loginView loadRequestWithURL:[NSURL URLWithString:urlString]];
    [loginView showLoginView:YES];
    [loginView release];
}

#pragma mark - GTLoginViewDelegate Methods
- (void)authorizeWebView:(GTLoginView *)webView didReceiveString:(NSString *)string {
    [webView hideLoginView:YES];
    // if not canceled
    NSString *token = [self getValueStringFromUrl:string forParam:@"access_token"];
    NSString *expTime = [self getValueStringFromUrl:string forParam:@"expires_in"];
    NSInteger expirationInt = [expTime intValue];
    
    BOOL success = NO;
    
    success = token && expTime;
    
    if (success && [delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:userID:expiresIn:)]) {
        [delegate authorize:self didSucceedWithAccessToken:token userID:@"" expiresIn:expirationInt];
    }
    // should not be possible
    if (!success && [delegate respondsToSelector:@selector(authorize:didFailWithError:)]) {
        NSError *error = [NSError errorWithDomain:nil 
                                             code:110 
                                         userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", @"授权失败"] forKey:@"WeiBoAuthorError"]];
        [delegate authorize:self didFailWithError:error];
    }
}

- (void)authorizeWebView:(GTLoginView *)webView cancel:(BOOL)cancel {
    if ([delegate respondsToSelector:@selector(authorize:didCancel:)]) {
        [delegate authorize:self didCancel:YES];
    }
}

@end
