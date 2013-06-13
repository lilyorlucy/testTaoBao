//
//  GTAuthorize.h
//  PocoCamera2
//
//  Created by GTL on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTLoginView.h"
#import "GTRequest.h"

@class GTAuthorize;

@protocol GTAuthorizeDelegate <NSObject>
@required
- (void)authorize:(GTAuthorize *)authorize didSucceedWithAccessToken:(NSString *)accessToken userID:(NSString *)userID expiresIn:(NSInteger)seconds;
- (void)authorize:(GTAuthorize *)authorize didFailWithError:(NSError *)error;
- (void)authorize:(GTAuthorize *)authorize didCancel:(BOOL)cancel;
@end

@interface GTAuthorize : NSObject  <GTLoginViewDelegate, GTRequestDelegate> {
    NSString    *appKey;
    NSString    *appSecret;
    GTRequest   *request;
    id<GTAuthorizeDelegate> delegate;
}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) GTRequest *request;
@property (nonatomic, assign) id<GTAuthorizeDelegate> delegate;

- (void)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;
- (void)startAuthorize;

@end
