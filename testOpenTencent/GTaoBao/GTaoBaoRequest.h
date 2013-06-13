//
//  GTaoBaoRequest.h
//  PocoCamera2
//
//  Created by GTL on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBUtil.h"
#import "JSON.h"
#import "GTaoBaoHeader.h"

typedef enum
{
    kGTaoBaoRequestPostDataTypeNone,
	kGTaoBaoRequestPostDataTypeNormal,			// for normal data post, such as "user=name&password=psd"
	kGTaoBaoRequestPostDataTypeMultipart,        // for uploading images and files.
}GTaoBaoRequestPostDataType;


@class GTaoBaoRequest;

@protocol GTaoBaoRequestDelegate <NSObject>
@optional

- (void)request:(GTaoBaoRequest *)request didFailWithError:(NSError *)error;
- (void)request:(GTaoBaoRequest *)request didFinishLoadingWithResult:(id)result;

@end

@interface GTaoBaoRequest : NSObject {
    id<GTaoBaoRequestDelegate>   delegate;
    NSString                *url;
    NSString                *httpMethod;
    NSDictionary            *params;
    GTaoBaoRequestPostDataType   postDataType;
    NSDictionary            *httpHeaderFields;
    NSURLConnection         *connection;
    NSMutableData           *responseData;
}
@property (nonatomic, assign) id<GTaoBaoRequestDelegate> delegate;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSDictionary *params;
@property GTaoBaoRequestPostDataType postDataType;
@property (nonatomic, retain) NSDictionary *httpHeaderFields;

+ (GTaoBaoRequest *)requestWithURL:(NSString *)url 
                   httpMethod:(NSString *)httpMethod 
                       params:(NSDictionary *)params
                 postDataType:(GTaoBaoRequestPostDataType)postDataType
             httpHeaderFields:(NSDictionary *)httpHeaderFields
                     delegate:(id<GTaoBaoRequestDelegate>)delegate;

+ (GTaoBaoRequest *)requestWithAccessToken:(NSString *)accessToken
                                  url:(NSString *)url
                           httpMethod:(NSString *)httpMethod 
                               params:(NSDictionary *)params
                         postDataType:(GTaoBaoRequestPostDataType)postDataType
                     httpHeaderFields:(NSDictionary *)httpHeaderFields
                             delegate:(id<GTaoBaoRequestDelegate>)delegate;

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;

- (void)connect;
- (void)disconnect;

@end
