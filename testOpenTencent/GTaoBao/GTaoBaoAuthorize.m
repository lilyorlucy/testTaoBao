//
//  GTaoBaoAuthorize.m
//  PocoCamera2
//
//  Created by GTL on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTaoBaoAuthorize.h"

@interface GTaoBaoAuthorize (Private)

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code;

@end

@implementation GTaoBaoAuthorize
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

#pragma mark PrivateMethods
- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"client_id",
                            appSecret, @"client_secret",
                            @"authorization_code", @"grant_type",
                            kGTRedirectURI, @"redirect_uri",
                            code, @"code", nil];
    [request disconnect];
    
    self.request = [GTaoBaoRequest requestWithURL:kGTAccessTokenURL
                                  httpMethod:@"POST"
                                      params:params
                                postDataType:kGTaoBaoRequestPostDataTypeNormal
                            httpHeaderFields:nil 
                                    delegate:self];
    [request connect];
}

#pragma mark Public Methods
- (void)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret {
    self.appKey = theAppKey;
    self.appSecret = theAppSecret;
}

- (void)startAuthorize {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:appKey forKey:@"client_id"];
    [parameters setValue:kGTRedirectURI forKey:@"redirect_uri"];
    [parameters setValue:@"code" forKey:@"response_type"];
    [parameters setValue:@"wap" forKey:@"view"];
    NSArray *permissions = [NSArray arrayWithObjects:@"item",@"promotion",@"usergrade",nil];
    NSString *permissionScope = [permissions componentsJoinedByString:@","];
    [parameters setValue:permissionScope forKey:@"scope"];
    
    NSString *urlString = [GTaoBaoRequest serializeURL:kGTaoBaoAuthorizeURL
                                           params:parameters
                                       httpMethod:@"GET"];
    
    NSLog(@"urlString:%@", urlString);
    GTaoBaoLoginView *loginView = [[GTaoBaoLoginView alloc] init];
    [loginView setDelegate:self];
    [loginView loadRequestWithURL:[NSURL URLWithString:urlString]];
    [loginView showLoginView:YES];
    [loginView release];
}

#pragma mark - GTaoBaoLoginViewDelegate Methods
- (void)authorizeWebView:(GTaoBaoLoginView *)webView didReceiveString:(NSString *)string {
    [webView hideLoginView:YES];
    // if not canceled
    if (![string isEqualToString:@"21330"]) {
        [self requestAccessTokenWithAuthorizeCode:string];
    } else {
        if ([delegate respondsToSelector:@selector(authorize:didCancel:)]) {
            [delegate authorize:self didCancel:YES];
        }
    }
}

- (void)authorizeWebView:(GTaoBaoLoginView *)webView cancel:(BOOL)cancel {
    if ([delegate respondsToSelector:@selector(authorize:didCancel:)]) {
        [delegate authorize:self didCancel:YES];
    }
}

#pragma mark - GTaoBaoRequestDelegate Methods
- (void)request:(GTaoBaoRequest *)theRequest didFinishLoadingWithResult:(id)result {
    BOOL success = NO;
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)result;
        NSLog(@"dict:%@", dict);
        NSString *token = [dict objectForKey:@"access_token"];
        NSString *userID = [dict objectForKey:@"taobao_user_id"];
        NSString *taobao_user_nick = [dict objectForKey:@"taobao_user_nick"];
        NSInteger seconds = [[dict objectForKey:@"expires_in"] intValue];
        
        success = token && userID;
        
        if (success && [delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:userID:expiresIn:taobao_user_nick:)]) {
            [delegate authorize:self didSucceedWithAccessToken:token userID:userID expiresIn:seconds taobao_user_nick:taobao_user_nick];
        }
    }
    
    // should not be possible
    if (!success && [delegate respondsToSelector:@selector(authorize:didFailWithError:)]) {
        NSError *error = [NSError errorWithDomain:nil 
                                             code:110 
                                         userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", @"授权失败"] forKey:@"WeiBoAuthorError"]];
        [delegate authorize:self didFailWithError:error];
    }
}

- (void)request:(GTaoBaoRequest *)theReqest didFailWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(authorize:didFailWithError:)]) {
        [delegate authorize:self didFailWithError:error];
    }
}

@end
