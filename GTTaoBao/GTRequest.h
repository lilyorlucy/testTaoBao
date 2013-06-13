//
//  GTRequest.h
//  PocoCamera2
//
//  Created by GTL on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBUtil.h"
#import "JSON.h"
#import "GTHeader.h"

typedef enum
{
    kGTRequestPostDataTypeNone,
	kGTRequestPostDataTypeNormal,			// for normal data post, such as "user=name&password=psd"
	kGTRequestPostDataTypeMultipart,        // for uploading images and files.
}GTRequestPostDataType;


@class GTRequest;

@protocol GTRequestDelegate <NSObject>
@optional

- (void)request:(GTRequest *)request didFailWithError:(NSError *)error;
- (void)request:(GTRequest *)request didFinishLoadingWithResult:(id)result;

@end

@interface GTRequest : NSObject {
    id<GTRequestDelegate>   delegate;
    NSString                *url;
    NSString                *httpMethod;
    NSDictionary            *params;
    GTRequestPostDataType   postDataType;
    NSURLConnection         *connection;
    NSMutableData           *responseData;
}
@property (nonatomic, assign) id<GTRequestDelegate> delegate;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSDictionary *params;
@property GTRequestPostDataType postDataType;

+ (GTRequest *)requestWithURL:(NSString *)url 
                   httpMethod:(NSString *)httpMethod 
                       params:(NSDictionary *)params
                 postDataType:(GTRequestPostDataType)postDataType
                     delegate:(id<GTRequestDelegate>)delegate;

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;

- (void)connect;
- (void)disconnect;

@end
