//
//  GTaoBaoHeader.h
//  PocoCamera2
//
//  Created by GTL on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef PocoCamera2_GTaoBaoHeader_h
#define PocoCamera2_GTaoBaoHeader_h

#define SHARENAME NSLocalizedString(@"淘宝网登录", nil)
#define kGTaoBaoAuthorizeURL     @"https://oauth.taobao.com/authorize"
#define kGTAccessTokenURL        @"https://oauth.taobao.com/token"
#define kGTSDKAPIDomain          @"https://eco.taobao.com/router/rest"

#define kGTRedirectURI @"http://www.shumaguo.cn"

#define kGTAppKey    @"21400536"
#define kGTAppSecret    @"282574194f03a7469a2429b6026a3c1b"

#define kGTaoBaoRequestTimeOutInterval   60.0
#define kGTaoBaoRequestStringBoundary    @"293iosfksdfkiowjksdf31jsiuwq003s02dsaffafass3qw"

#endif

#define kGTSDKErrorDomain           @"WeiBoSDKErrorDomain"
#define kGTSDKErrorCodeKey          @"WeiBoSDKErrorCodeKey"

#define kGTURLSchemePrefix              @"GT_"
#define kGTKeychainNickNameSuffix    @"_WeiBoServiceName"
#define kGTKeychainUserID               @"WeiBoUserID"
#define kGTKeychainAccessToken          @"WeiBoAccessToken"
#define kGTKeychainExpireTime           @"WeiBoExpireTime"


typedef enum
{
	kGTErrorCodeInterface	= 100,
	kGTErrorCodeSDK         = 101,
}GTErrorCode;

typedef enum
{
	kGTSDKErrorCodeParseError       = 200,
	kGTSDKErrorCodeRequestError     = 201,
	kGTSDKErrorCodeAccessError      = 202,
	kGTSDKErrorCodeAuthorizeError	= 203,
}GTSDKErrorCode;






