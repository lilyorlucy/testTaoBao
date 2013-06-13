//
//  GTHeader.h
//  PocoCamera2
//
//  Created by GTL on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ROUtility.h"

#ifndef PocoCamera2_GTHeader_h
#define PocoCamera2_GTHeader_h

#define SHARENAME NSLocalizedString(@"淘宝网登录", nil)
#define kGTAuthorizeURL     @"https://oauth.taobao.com/authorize"
#define kRRSessionKeyURL        @"https://oauth.taobao.com/token"
#define kGTRestserverBaseURL      @"http://api.renren.com/restserver.do"
#define kSDKversion             @"3.0"

#define kCallbackURL           @"http://www.shumaguo.cn"
#define kWidgetDialogUA  @"18da8a1a68e2ee89805959b6c8441864"

//#ifdef BEAUTY_CAMERA
#define kGTAppKey    @"12660963"
#define kGTAppSecret    @"e73dce69e6b337bd1abf17d70c004c24"
//#else
//#define kGTAppSecret     @"179188"
//#define kGTAppKey    @"13b4ef4e5b9046e9a0c7fbd79d0292c2"
//#endif

#define kGTRedirectURI @"http://www.shumaguo.cn"

#define kGTRequestTimeOutInterval   60.0

#endif

#define kGTSDKErrorDomain           @"WeiBoSDKErrorDomain"
#define kGTSDKErrorCodeKey          @"WeiBoSDKErrorCodeKey"
#define kGTSDKAPIDomain             @"https://api.weibo.com/2/"

#define kGTURLSchemePrefix              @"GT_"
#define kGTKeychainServiceNameSuffix    @"_WeiBoServiceName"
#define kGTKeychainUserID               @"WeiBoUserID"
#define kGTKeychainAccessToken          @"WeiBoAccessToken"
#define kGTKeychainExpireTime           @"WeiBoExpireTime"

#define kGTKeychainSecret               @"WeiBoSecret"
#define kGTKeychainSessionKey           @"WeiBoSessionKey"


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

static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3";
static NSString* kUserAgent = @"Renren iOS SDK v3.0";



