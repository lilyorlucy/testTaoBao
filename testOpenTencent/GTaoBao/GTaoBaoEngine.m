//
//  GTaoBaoEngine.m
//  PocoCamera2
//
//  Created by admin on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTaoBaoEngine.h"
#import "GTaoBaoHeader.h"

@interface GTaoBaoEngine (Private)
- (NSString *)weiboAuthorPath;
- (void)saveAuthorizeDataToKeychain;
- (void)readAuthorizeDataFromKeychain;
- (void)deleteAuthorizeDataInKeychain;

@end


@implementation GTaoBaoEngine

@synthesize tag;
@synthesize appKey;
@synthesize appSecret;
@synthesize userID;
@synthesize accessToken;
@synthesize expireTime;
@synthesize redirectURI;
@synthesize isUserExclusive;
@synthesize request;
@synthesize authorize;
@synthesize delegate;
@synthesize nickName;

#pragma mark - GTaoBaoEngine Life Circle
- (id)init {
    if (self = [super init]) {
        self.appKey = kGTAppKey;
        self.appSecret = kGTAppSecret;    
        self.redirectURI = kGTRedirectURI;
        isUserExclusive = NO;        
        [self readAuthorizeDataFromKeychain];
    }
    return self;
}

- (void)dealloc {
    [nickName release], nickName = nil;
    [appKey release], appKey = nil;
    [appSecret release], appSecret = nil;
    [userID release], userID = nil;
    [accessToken release], accessToken = nil;
    [redirectURI release], redirectURI = nil;
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;    
    [authorize setDelegate:nil];
    [authorize release], authorize = nil;    
    delegate = nil;
    [super dealloc];
}

#pragma mark - GTaoBaoEngine Private Methods
- (NSString *)weiboAuthorPath {
	NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *sendListPath = [documentsDir stringByAppendingPathComponent:@"taobaoAuthorToken.plist"];
	return sendListPath;
}


- (void)saveAuthorizeDataToKeychain {
    NSString *taobaoPath = [self weiboAuthorPath];
    NSMutableDictionary *taobaoTokenDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    [taobaoTokenDic setObject:userID forKey:kGTKeychainUserID];
    [taobaoTokenDic setObject:accessToken forKey:kGTKeychainAccessToken];
    [taobaoTokenDic setObject:nickName forKey:kGTKeychainNickNameSuffix];
    [taobaoTokenDic setObject:[NSString stringWithFormat:@"%lf", expireTime] forKey:kGTKeychainExpireTime];
    [taobaoTokenDic writeToFile:taobaoPath atomically:YES];
    [taobaoTokenDic release];
}

- (void)readAuthorizeDataFromKeychain {
    NSString *taobaoPath = [self weiboAuthorPath];
	NSMutableDictionary *taobaoTokenDic = [[NSMutableDictionary alloc] initWithContentsOfFile:taobaoPath];
    self.userID = [taobaoTokenDic objectForKey:kGTKeychainUserID];
	self.accessToken = [taobaoTokenDic objectForKey:kGTKeychainAccessToken];
	self.expireTime = [[taobaoTokenDic objectForKey:kGTKeychainExpireTime] doubleValue];
    self.nickName = [taobaoTokenDic objectForKey:kGTKeychainNickNameSuffix];
    [taobaoTokenDic release];
}

- (void)deleteAuthorizeDataInKeychain {
    self.userID = @"";
    self.accessToken = @"";
    self.expireTime = 0;    
    NSString *taobaoPath = [self weiboAuthorPath];
    NSMutableDictionary *taobaoTokenDic = [[NSMutableDictionary alloc] initWithContentsOfFile:taobaoPath];
    [taobaoTokenDic removeAllObjects];
    [taobaoTokenDic setObject:userID forKey:kGTKeychainUserID];
    [taobaoTokenDic setObject:accessToken forKey:kGTKeychainAccessToken];
    [taobaoTokenDic setObject:[NSString stringWithFormat:@"%lf", expireTime] forKey:kGTKeychainExpireTime];
    [taobaoTokenDic writeToFile:taobaoPath atomically:YES];
    [taobaoTokenDic release];
}

#pragma mark - GTaoBaoEngine Public Methods
#pragma mark Authorization
- (void)logIn {
    if ([self isLoggedIn]) {
        if ([delegate respondsToSelector:@selector(engineAlreadyLoggedIn:)]) {
            [delegate engineAlreadyLoggedIn:self];
        }
        if (isUserExclusive) {
            return;
        }
    }
    
    GTaoBaoAuthorize *auth = [[GTaoBaoAuthorize alloc] init];
    [auth setDelegate:self];
    self.authorize = auth;
    [auth release];
    [authorize startAuthorize];
}

- (void)logOut {
    [self deleteAuthorizeDataInKeychain];    
    if ([delegate respondsToSelector:@selector(engineDidLogOut:)]) {
        [delegate engineDidLogOut:self];
    }
}

- (BOOL)isLoggedIn {
    return userID && accessToken && (expireTime > 0);
}

- (BOOL)isAuthorizeExpired {
    if ([[NSDate date] timeIntervalSince1970] > expireTime) {
        // force to log out
        [self deleteAuthorizeDataInKeychain];
        return YES;
    }
    return NO;
}

#pragma mark - GTaoBaoAuthorizeDelegate Methods
- (void)authorize:(GTaoBaoAuthorize *)authorize didSucceedWithAccessToken:(NSString *)theAccessToken userID:(NSString *)theUserID expiresIn:(NSInteger)seconds taobao_user_nick:(NSString *)nick {
    self.accessToken = theAccessToken;
    self.userID = theUserID;
    self.expireTime = [[NSDate date] timeIntervalSince1970] + seconds;
    self.nickName = nick;
    [self saveAuthorizeDataToKeychain];
    if ([delegate respondsToSelector:@selector(engineDidLogIn:)]) {
        [delegate engineDidLogIn:self];
    }
}

- (void)authorize:(GTaoBaoAuthorize *)authorize didFailWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(engine:didFailToLogInWithError:)]) {
        [delegate engine:self didFailToLogInWithError:error];
    }
}

- (void)authorize:(GTaoBaoAuthorize *)authorize didCancel:(BOOL)cancel {
    if ([delegate respondsToSelector:@selector(engine:didCancel:)]) {
        [delegate engine:self didCancel:YES];
    }
}

#pragma mark Request
- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(GTaoBaoRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields {
	if (![self isLoggedIn])	{
        if ([delegate respondsToSelector:@selector(engineNotAuthorized:)]) {
            [delegate engineNotAuthorized:self];
        }
        return;
	}
    if ([self isAuthorizeExpired]) {
        if ([delegate respondsToSelector:@selector(engineAuthorizeExpired:)]) {
            [delegate engineAuthorizeExpired:self];
        }
        return;
    }
    [request disconnect];
    self.request = [GTaoBaoRequest requestWithAccessToken:accessToken
                                                 url:[NSString stringWithFormat:@"%@%@", kGTSDKAPIDomain, methodName]
                                          httpMethod:httpMethod
                                              params:params
                                        postDataType:postDataType
                                    httpHeaderFields:httpHeaderFields
                                            delegate:self];
	[request connect];
}

#pragma mark API
- (void)sendWeiBoWithText:(NSString *)text image:(UIImage *)image {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
	[params setObject:(text ? text : @"") forKey:@"status"];
    if (image) {
		[params setObject:image forKey:@"pic"];
        [self loadRequestWithMethodName:@"statuses/upload.json"
                             httpMethod:@"POST"
                                 params:params
                           postDataType:kGTaoBaoRequestPostDataTypeMultipart
                       httpHeaderFields:nil];
    }
    else {
        [self loadRequestWithMethodName:@"statuses/update.json"
                             httpMethod:@"POST"
                                 params:params
                           postDataType:kGTaoBaoRequestPostDataTypeNormal
                       httpHeaderFields:nil];
    }
}

- (void)sendWeiBoWithText:(NSString *)text imageData:(NSData *)imageData {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   imageData, @"pic",
                                   text, @"status",
                                   nil];
    [self loadRequestWithMethodName:@"statuses/upload.json"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kGTaoBaoRequestPostDataTypeMultipart
                   httpHeaderFields:nil];
}

- (void)sendWeiBoWithParams:(NSDictionary *)params {
    [self loadRequestWithMethodName:@"statuses/upload.json"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kGTaoBaoRequestPostDataTypeMultipart
                   httpHeaderFields:nil];
}

- (void)getFriendShipsWithParams:(NSDictionary *)params {
    [self loadRequestWithMethodName:@"friendships/friends.json"
                         httpMethod:@"GET"
                             params:params
                       postDataType:kGTaoBaoRequestPostDataTypeNone
                   httpHeaderFields:nil];
}

- (void)createFriendWithParams:(NSDictionary *)params {
    [self loadRequestWithMethodName:@"friendships/create.json"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kGTaoBaoRequestPostDataTypeNormal
                   httpHeaderFields:nil];
}

- (void)getUserTimeLineWithParams:(NSDictionary *)params {
    [self loadRequestWithMethodName:@"statuses/user_timeline.json"
                         httpMethod:@"GET"
                             params:params
                       postDataType:kGTaoBaoRequestPostDataTypeNone
                   httpHeaderFields:nil];
}

- (void)getHotWithParams:(NSDictionary *)params {
    [self loadRequestWithMethodName:@"statuses/hot/repost_daily.json"
                         httpMethod:@"GET"
                             params:params
                       postDataType:kGTaoBaoRequestPostDataTypeNone
                   httpHeaderFields:nil];
}

- (void)getUserInfo {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"taobao.user.buyer.get", @"method", @"2.0", @"v", @"json", @"format", nil];
    [params setObject:@"user_id,uid,nick,sex,buyer_credit,seller_credit,location,created,last_visit,birthday,type,status,alipay_no,alipay_account,alipay_account,email,consumer_protection,alipay_bind,avatar" forKey:@"fields"];
    [self loadRequestWithMethodName:@""
                         httpMethod:@"GET"
                             params:params
                       postDataType:kGTaoBaoRequestPostDataTypeNone
                   httpHeaderFields:nil];
}

#pragma mark - GTaoBaoRequestDelegate Methods
- (void)request:(GTaoBaoRequest *)request didFinishLoadingWithResult:(id)result {
    NSLog(@"result:%@", result);
    if ([delegate respondsToSelector:@selector(engine:requestDidSucceedWithResult:)]) {
        [delegate engine:self requestDidSucceedWithResult:result];
    }
}

- (void)request:(GTaoBaoRequest *)request didFailWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(engine:requestDidFailWithError:)]) {
        [delegate engine:self requestDidFailWithError:error];
    }
}

@end
