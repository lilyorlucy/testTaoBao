//
//  GTaoBaoEngine.h
//  PocoCamera2
//
//  Created by admin on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTaoBaoAuthorize.h"
#import "GTaoBaoRequest.h"

@class GTaoBaoEngine;

@protocol GTaoBaoEngineDelegate <NSObject>

@optional
- (void)engineAlreadyLoggedIn:(GTaoBaoEngine *)engine;
- (void)engineDidLogOut:(GTaoBaoEngine *)engine;
- (void)engineNotAuthorized:(GTaoBaoEngine *)engine;
- (void)engineAuthorizeExpired:(GTaoBaoEngine *)engine;

- (void)engineDidLogIn:(GTaoBaoEngine *)engine;
- (void)engine:(GTaoBaoEngine *)engine didFailToLogInWithError:(NSError *)error;
- (void)engine:(GTaoBaoEngine *)engine didCancel:(BOOL)cancel;

- (void)engine:(GTaoBaoEngine *)engine requestDidFailWithError:(NSError *)error;
- (void)engine:(GTaoBaoEngine *)engine requestDidSucceedWithResult:(id)result;

@end

@interface GTaoBaoEngine : NSObject <GTaoBaoAuthorizeDelegate, GTaoBaoRequestDelegate> {
    id<GTaoBaoEngineDelegate> delegate;
    NSString        *appKey;
    NSString        *appSecret;
    NSString        *userID;
    NSString        *accessToken;
    NSTimeInterval  expireTime;
    NSString        *redirectURI;    
    // Determine whether user must log out before another logging in.
    BOOL            isUserExclusive;    
    GTaoBaoRequest       *request;
    GTaoBaoAuthorize     *authorize;    
    NSInteger tag;
    NSString *nickName;
}
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, assign) NSTimeInterval expireTime;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, assign) BOOL isUserExclusive;
@property (nonatomic, retain) GTaoBaoRequest *request;
@property (nonatomic, retain) GTaoBaoAuthorize *authorize;
@property (nonatomic, assign) id<GTaoBaoEngineDelegate> delegate;

- (void)logIn;
- (void)logOut;

- (BOOL)isLoggedIn;
- (BOOL)isAuthorizeExpired;

- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(GTaoBaoRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields;

- (void)sendWeiBoWithText:(NSString *)text image:(UIImage *)image;
- (void)sendWeiBoWithText:(NSString *)text imageData:(NSData *)imageData;
- (void)sendWeiBoWithParams:(NSDictionary *)params;
- (void)getFriendShipsWithParams:(NSDictionary *)params;
- (void)createFriendWithParams:(NSDictionary *)params;
- (void)getUserTimeLineWithParams:(NSDictionary *)params;
- (void)getHotWithParams:(NSDictionary *)params;
- (void)getUserInfo;

@end
