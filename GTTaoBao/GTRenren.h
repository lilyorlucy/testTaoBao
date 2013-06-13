//
//  GTRenren.h
//  PocoCamera2
//
//  Created by admin on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTAuthorize.h"
#import "GTRequest.h"

@class GTRenren;

@protocol GTRenrenDelegate <NSObject>

@optional
- (void)renrenAlreadyLoggedIn:(GTRenren *)renren;
- (void)renrenDidLogOut:(GTRenren *)renren;
- (void)renrenNotAuthorized:(GTRenren *)renren;
- (void)renrenAuthorizeExpired:(GTRenren *)renren;

- (void)renrenDidLogIn:(GTRenren *)renren;
- (void)renren:(GTRenren *)renren didFailToLogInWithError:(NSError *)error;
- (void)renren:(GTRenren *)renren didCancel:(BOOL)cancel;

- (void)renren:(GTRenren *)renren requestDidFailWithError:(NSError *)error;
- (void)renren:(GTRenren *)renren requestDidSucceedWithResult:(id)result;

@end

@interface GTRenren : NSObject <GTAuthorizeDelegate, GTRequestDelegate> {
    id<GTRenrenDelegate> delegate;
    NSString        *appKey;
    NSString        *appSecret;
    NSString        *userID;
    NSString        *accessToken;
    NSString        *secret;
    NSString        *sessionKey;
    NSTimeInterval  expireTime;
    NSString        *redirectURI;    
    // Determine whether user must log out before another logging in.
    BOOL            isUserExclusive;    
    GTRequest       *request;
    GTAuthorize     *authorize;    
    NSInteger tag;
}
@property (nonatomic, retain) NSString *secret;
@property (nonatomic, retain) NSString *sessionKey;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, assign) NSTimeInterval expireTime;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, assign) BOOL isUserExclusive;
@property (nonatomic, retain) GTRequest *request;
@property (nonatomic, retain) GTAuthorize *authorize;
@property (nonatomic, assign) id<GTRenrenDelegate> delegate;

+ (GTRenren *)sharedRenren;
- (void)logIn;
- (void)logOut;

- (BOOL)isLoggedIn;
- (BOOL)isAuthorizeExpired;

- (void)loadRequestWithHttpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(GTRequestPostDataType)postDataType;

- (void)getUserInfo;
- (void)sendImageWithContent:(NSString *)text imageData:(NSData *)imageData;
- (void)sharePictureWithParams:(NSDictionary *)paramsDic;
- (void)getFriendShipsWithParams:(NSDictionary *)params;

@end
