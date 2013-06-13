//
//  GTaoBaoAuthorize.h
//  PocoCamera2
//
//  Created by GTL on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTaoBaoLoginView.h"
#import "GTaoBaoRequest.h"

@class GTaoBaoAuthorize;

@protocol GTaoBaoAuthorizeDelegate <NSObject>
@required
- (void)authorize:(GTaoBaoAuthorize *)authorize didSucceedWithAccessToken:(NSString *)theAccessToken userID:(NSString *)theUserID expiresIn:(NSInteger)seconds taobao_user_nick:(NSString *)nick;
- (void)authorize:(GTaoBaoAuthorize *)authorize didFailWithError:(NSError *)error;
- (void)authorize:(GTaoBaoAuthorize *)authorize didCancel:(BOOL)cancel;
@end

@interface GTaoBaoAuthorize : NSObject  <GTaoBaoLoginViewDelegate, GTaoBaoRequestDelegate> {
    NSString    *appKey;
    NSString    *appSecret;
    GTaoBaoRequest   *request;
    id<GTaoBaoAuthorizeDelegate> delegate;
}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) GTaoBaoRequest *request;
@property (nonatomic, assign) id<GTaoBaoAuthorizeDelegate> delegate;

- (void)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;
- (void)startAuthorize;

@end
