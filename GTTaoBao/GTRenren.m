//
//  GTRenren.m
//  PocoCamera2
//
//  Created by admin on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTRenren.h"
#import "GTHeader.h"

@interface GTRenren (Private)
- (NSString *)weiboAuthorPath;
- (void)saveAuthorizeDataToKeychain;
- (void)readAuthorizeDataFromKeychain;
- (void)deleteAuthorizeDataInKeychain;
- (NSMutableDictionary*)requestDictionary;

@end


@implementation GTRenren

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
@synthesize secret;
@synthesize sessionKey;

#pragma mark - GTRenren Life Circle
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

static GTRenren *sharedRenren = nil;
+ (GTRenren *)sharedRenren {
    if (!sharedRenren) {
        sharedRenren = [[GTRenren alloc] init];
        [sharedRenren isLoggedIn];
        sharedRenren.appKey = kGTAppKey;
        sharedRenren.appSecret = kGTAppSecret;    
    }
    return sharedRenren;
}

- (void)dealloc {
    [sharedRenren release];
    sharedRenren = nil;
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

#pragma mark - GTRenren Private Methods
- (NSString *)weiboAuthorPath {
	NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
    NSString *tokenPath = [NSString stringWithFormat:@"%@AuthorToken.plist", SHARENAME];
	NSString *sendListPath = [documentsDir stringByAppendingPathComponent:tokenPath];
	return sendListPath;
}


- (void)saveAuthorizeDataToKeychain {
    NSString *sinaPath = [self weiboAuthorPath];
    NSMutableDictionary *sinaTokenDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    [sinaTokenDic setObject:userID forKey:kGTKeychainUserID];
    [sinaTokenDic setObject:accessToken forKey:kGTKeychainAccessToken];
    [sinaTokenDic setObject:[NSString stringWithFormat:@"%lf", expireTime] forKey:kGTKeychainExpireTime];
    [sinaTokenDic setObject:secret forKey:kGTKeychainSecret];
    [sinaTokenDic setObject:sessionKey forKey:kGTKeychainSessionKey];
    [sinaTokenDic writeToFile:sinaPath atomically:YES];
    [sinaTokenDic release];
}

- (void)readAuthorizeDataFromKeychain {
    NSString *sinaPath = [self weiboAuthorPath];
	NSMutableDictionary *sinaTokenDic = [[NSMutableDictionary alloc] initWithContentsOfFile:sinaPath];
    self.userID = [sinaTokenDic objectForKey:kGTKeychainUserID];
	self.accessToken = [sinaTokenDic objectForKey:kGTKeychainAccessToken];
	self.expireTime = [[sinaTokenDic objectForKey:kGTKeychainExpireTime] doubleValue];
    self.secret = [sinaTokenDic objectForKey:kGTKeychainSecret];
    self.sessionKey = [sinaTokenDic objectForKey:kGTKeychainSessionKey];
    [sinaTokenDic release];
}

- (void)deleteAuthorizeDataInKeychain {
    self.userID = @"";
    self.accessToken = @"";
    self.expireTime = 0;
    self.sessionKey = @"";
    self.secret = @"";
    NSString *sinaPath = [self weiboAuthorPath];
    NSMutableDictionary *sinaTokenDic = [[NSMutableDictionary alloc] initWithContentsOfFile:sinaPath];
    [sinaTokenDic removeAllObjects];
    [sinaTokenDic setObject:userID forKey:kGTKeychainUserID];
    [sinaTokenDic setObject:accessToken forKey:kGTKeychainAccessToken];
    [sinaTokenDic setObject:[NSString stringWithFormat:@"%lf", expireTime] forKey:kGTKeychainExpireTime];
    [sinaTokenDic setObject:secret forKey:kGTKeychainSecret];
    [sinaTokenDic setObject:sessionKey forKey:kGTKeychainSessionKey];
    [sinaTokenDic writeToFile:sinaPath atomically:YES];
    [sinaTokenDic release];
}

- (NSMutableDictionary*)requestDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"json", @"format",
                                       kSDKversion, @"v",
                                       self.appKey, @"api_key",
                                       self.sessionKey, @"session_key",
                                       [ROUtility generateCallId], @"call_id",
                                       @"1", @"xn_ss", nil];
	
	return dictionary;
}

#pragma mark - GTRenren Public Methods
#pragma mark Authorization
- (void)logIn {
    GTAuthorize *auth = [[GTAuthorize alloc] init];
    [auth setDelegate:self];
    self.authorize = auth;
    [auth release];
    [authorize startAuthorize];
}

- (void)logOut {
    [self deleteAuthorizeDataInKeychain];    
    if ([delegate respondsToSelector:@selector(renrenDidLogOut:)]) {
        [delegate renrenDidLogOut:self];
    }
}

- (BOOL)isLoggedIn {
    [self readAuthorizeDataFromKeychain];
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

#pragma mark - GTAuthorizeDelegate Methods
- (void)authorize:(GTAuthorize *)authorize didSucceedWithAccessToken:(NSString *)theAccessToken userID:(NSString *)theUserID expiresIn:(NSInteger)seconds {
    self.accessToken = theAccessToken;
    self.userID = theUserID;
    self.expireTime = [[NSDate date] timeIntervalSince1970] + seconds;
    self.secret = [ROUtility getSecretKeyByToken:theAccessToken];
    self.sessionKey = [ROUtility getSessionKeyByToken:theAccessToken];	
    [self saveAuthorizeDataToKeychain];
    if ([delegate respondsToSelector:@selector(renrenDidLogIn:)]) {
        [delegate renrenDidLogIn:self];
    }
}

- (void)authorize:(GTAuthorize *)authorize didFailWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(renren:didFailToLogInWithError:)]) {
        [delegate renren:self didFailToLogInWithError:error];
    }
}

- (void)authorize:(GTAuthorize *)authorize didCancel:(BOOL)cancel {
    if ([delegate respondsToSelector:@selector(renren:didCancel:)]) {
        [delegate renren:self didCancel:YES];
    }
}

#pragma mark Request
- (void)loadRequestWithHttpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(GTRequestPostDataType)postDataType {
	if (![self isLoggedIn])	{
        if ([delegate respondsToSelector:@selector(renrenNotAuthorized:)]) {
            [delegate renrenNotAuthorized:self];
        }
        return;
	}
    if ([self isAuthorizeExpired]) {
        if ([delegate respondsToSelector:@selector(renrenAuthorizeExpired:)]) {
            [delegate renrenAuthorizeExpired:self];
        }
        return;
    }
    [request disconnect];
    self.request = [GTRequest requestWithURL:kGTRestserverBaseURL httpMethod:httpMethod params:params postDataType:postDataType delegate:self];
	[request connect];
}

#pragma mark API
- (void)getUserInfo {
    NSMutableDictionary *params = [self requestDictionary];
    [params setObject:@"users.getInfo" forKey:@"method"];
    NSString *sig = [ROUtility generateSig:params secretKey:self.secret];
    [params setObject:sig forKey:@"sig"];
	
    NSLog(@"params%@", params);
    [self loadRequestWithHttpMethod:@"POST"
                             params:params
                       postDataType:kGTRequestPostDataTypeNone];
    NSLog(@"api_key:%@", [params objectForKey:@"api_key"]);
}

- (void)sendImageWithContent:(NSString *)text imageData:(NSData *)imageData {
    NSMutableDictionary *params = [self requestDictionary];
    [params setObject:text forKey:@"caption"];
    [params setObject:@"photos.upload" forKey:@"method"];
    NSString *sig = [ROUtility generateSig:params secretKey:self.secret];
    [params setObject:sig forKey:@"sig"];
    NSLog(@"params:%@", params);
    [params setObject:imageData forKey:@"upload"];

    [self loadRequestWithHttpMethod:@"POST"
                             params:params
                       postDataType:kGTRequestPostDataTypeMultipart];
}

- (void)sharePictureWithParams:(NSDictionary *)paramsDic {
    NSMutableDictionary *params = [self requestDictionary];
    [params addEntriesFromDictionary:paramsDic];
    [params setObject:@"2" forKey:@"type"];
    [params setObject:@"share.share" forKey:@"method"];
    NSString *sig = [ROUtility generateSig:params secretKey:self.secret];
    [params setObject:sig forKey:@"sig"];
    NSLog(@"params:%@", params);
    
    [self loadRequestWithHttpMethod:@"POST"
                             params:params
                       postDataType:kGTRequestPostDataTypeNormal];
}

- (void)getFriendShipsWithParams:(NSDictionary *)params {
    NSMutableDictionary *paramsDic = [self requestDictionary];
    [paramsDic addEntriesFromDictionary:params];
    [paramsDic setObject:@"friends.getFriends" forKey:@"method"];
    NSString *sig = [ROUtility generateSig:paramsDic secretKey:self.secret];
    [paramsDic setObject:sig forKey:@"sig"];
    NSLog(@"params:%@", paramsDic);
    
    [self loadRequestWithHttpMethod:@"POST"
                             params:paramsDic
                       postDataType:kGTRequestPostDataTypeNormal];
}


#pragma mark - GTRequestDelegate Methods
- (void)request:(GTRequest *)request didFinishLoadingWithResult:(id)result {
    if ([delegate respondsToSelector:@selector(renren:requestDidSucceedWithResult:)]) {
        [delegate renren:self requestDidSucceedWithResult:result];
    }
}

- (void)request:(GTRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"error:%@", error.userInfo);
    if ([delegate respondsToSelector:@selector(renren:requestDidFailWithError:)]) {
        [delegate renren:self requestDidFailWithError:error];
    }
}

@end
