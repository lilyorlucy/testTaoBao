//
//  GTRequest.m
//  PocoCamera2
//
//  Created by GTL on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTRequest.h"

@interface GTRequest (Private)
+ (NSString *)stringFromDictionary:(NSDictionary *)dict;
+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString;

- (NSMutableData *)postBody;
- (void)handleResponseData:(NSData *)data;
- (id)parseJSONData:(NSData *)data error:(NSError **)error;
- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;
- (void)failedWithError:(NSError *)error;

@end

@implementation GTRequest

@synthesize url;
@synthesize httpMethod;
@synthesize params;
@synthesize postDataType;
@synthesize delegate;

#pragma mark Life Circle
- (void)dealloc {
    [url release], url = nil;
    [httpMethod release], httpMethod = nil;
    [params release], params = nil;
    [responseData release];
	responseData = nil;
    [connection cancel];
    [connection release], connection = nil;
    [super dealloc];
}

#pragma mark Private Methods
+ (NSString *)stringFromDictionary:(NSDictionary *)dict {
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator]) {
		if (!([[dict valueForKey:key] isKindOfClass:[NSString class]])) {
			continue;
		}
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[dict objectForKey:key] URLEncodedString]]];
	}
	return [pairs componentsJoinedByString:@"&"];
}

+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString {
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSMutableData *)generatePostBody {
	NSMutableData *body = [NSMutableData data];
	NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
	NSMutableArray *pairs = [NSMutableArray array];
    if (postDataType == kGTRequestPostDataTypeMultipart) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kStringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        for(NSString *key in [params keyEnumerator]){
            if ([key isEqualToString:@"upload"]) {
                continue;
            }
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name = \"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[params valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];
        }
        NSData *imageData=[params valueForKey:@"upload"];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\";filename=no.gif"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:@"Content-Type:image/*\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];  
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kStringBoundary] dataUsingEncoding:NSUTF8StringEncoding]]; 
    }else {
        for (NSString* key  in [params keyEnumerator]) {
            NSString* value = [params objectForKey:key];
            NSString* value_str = [ROUtility encodeString:value urlEncode:NSUTF8StringEncoding];
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value_str]];
        }
        NSString* param = [pairs componentsJoinedByString:@"&"];
        [body appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return body;
}

- (void)handleResponseData:(NSData *)data {
    NSError* error = nil;  
    id result = [self parseJsonResponse:data error:&error];
	if (error) {
		[self failedWithError:error];
	} 
	else {
        if ([delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)]) {
            [delegate request:self didFinishLoadingWithResult:(result == nil ? data : result)];
		}
	}
}

- (id)parseJsonResponse:(NSData *)data error:(NSError **)error{
    NSString* responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"Here's the response string: %@", responseString);
    SBJSON *jsonParser = [[SBJSON new] autorelease];
    if ([responseString isEqualToString:@"true"]) {
        return [NSDictionary dictionaryWithObject:@"true" forKey:@"result"];
    }else if([responseString isEqualToString:@"false"]) {
        if(error != nil){
            *error = [self errorWithCode:kGTErrorCodeSDK
                                userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kGTSDKErrorCodeParseError] forKey:kGTSDKErrorCodeKey]];
        }
        return nil;
    }
    id result = [jsonParser objectWithString:responseString];
    if (![result isKindOfClass:[NSArray class]]) {
        if([result objectForKey:@"error"] != nil){
            if (error != nil) {
                *error = [self errorWithCode:kGTErrorCodeInterface userInfo:result];
            }
            return nil;
        }
        if ([result objectForKey:@"error_code"] != nil) {
            if (error != nil) {
                *error = [self errorWithCode:kGTErrorCodeInterface userInfo:result];
            }
            return nil;
        }
        if ([result objectForKey:@"error_msg"] != nil) {
            if (error != nil) {
                *error = [self errorWithCode:kGTErrorCodeInterface userInfo:result];
            }
        }
        if ([result objectForKey:@"error_reason"] != nil) {
            if (error != nil) {
                *error = [self errorWithCode:kGTErrorCodeInterface userInfo:result];
            }
        }
    }
    return result;
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:kGTSDKErrorDomain code:code userInfo:userInfo];
}

- (void)failedWithError:(NSError *)error {
	if ([delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[delegate request:self didFailWithError:error];
	}
}

#pragma mark Public Methods
+ (GTRequest *)requestWithURL:(NSString *)url 
                   httpMethod:(NSString *)httpMethod 
                       params:(NSDictionary *)params
                 postDataType:(GTRequestPostDataType)postDataType
                     delegate:(id<GTRequestDelegate>)delegate {
    GTRequest *request = [[[GTRequest alloc] init] autorelease];
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.postDataType = postDataType;
    request.delegate = delegate;
    return request;
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod {
    if (![httpMethod isEqualToString:@"GET"]) {
        return baseURL;
    }
    
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
	NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString *query = [GTRequest stringFromDictionary:params];
	
	return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

- (void)connect {
//    NSString *urlString = [GTRequest serializeURL:url params:params httpMethod:httpMethod];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:kGTRequestTimeOutInterval];
    [request setHTTPMethod:httpMethod];
    UIDevice *device = [UIDevice currentDevice];
    NSString *ua = [NSString stringWithFormat:@"%@ (%@; %@ %@)",kUserAgent, device.model, device.systemName, device.systemVersion];
    [request setValue:ua forHTTPHeaderField:@"User-Agent"];
    if ([httpMethod isEqualToString:@"POST"]) {
        if (postDataType == kGTRequestPostDataTypeMultipart) {
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
        
        [request setHTTPBody:[self generatePostBody]];
    }
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)disconnect {
    [responseData release];
	responseData = nil;
    [connection cancel];
    [connection release], connection = nil;
}

#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
	[self handleResponseData:responseData];
    
	[responseData release];
	responseData = nil;
    [connection cancel];
	[connection release];
	connection = nil;
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
	[self failedWithError:error];
	
	[responseData release];
	responseData = nil;
    [connection cancel];
	[connection release];
	connection = nil;
}

@end
