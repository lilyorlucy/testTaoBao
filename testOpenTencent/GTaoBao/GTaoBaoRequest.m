//
//  GTaoBaoRequest.m
//  PocoCamera2
//
//  Created by GTL on 12-8-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTaoBaoRequest.h"

@interface GTaoBaoRequest (Private)
+ (NSString *)stringFromDictionary:(NSDictionary *)dict;
+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString;

- (NSMutableData *)postBody;
- (void)handleResponseData:(NSData *)data;
- (id)parseJSONData:(NSData *)data error:(NSError **)error;
- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;
- (void)failedWithError:(NSError *)error;

@end

@implementation GTaoBaoRequest

@synthesize url;
@synthesize httpMethod;
@synthesize params;
@synthesize postDataType;
@synthesize httpHeaderFields;
@synthesize delegate;

#pragma mark Life Circle
- (void)dealloc {
    [url release], url = nil;
    [httpMethod release], httpMethod = nil;
    [params release], params = nil;
    [httpHeaderFields release], httpHeaderFields = nil;
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

- (NSMutableData *)postBody {
    NSMutableData *body = [NSMutableData data];
    if (postDataType == kGTaoBaoRequestPostDataTypeNormal) {
        [GTaoBaoRequest appendUTF8Body:body dataString:[GTaoBaoRequest stringFromDictionary:params]];
    }
    else if (postDataType == kGTaoBaoRequestPostDataTypeMultipart) {
        NSString *bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", kGTaoBaoRequestStringBoundary];
		NSString *bodySuffixString = [NSString stringWithFormat:@"\r\n--%@--\r\n", kGTaoBaoRequestStringBoundary];
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        [GTaoBaoRequest appendUTF8Body:body dataString:bodyPrefixString];
        for (id key in [params keyEnumerator]) {
			if (([[params valueForKey:key] isKindOfClass:[UIImage class]]) || ([[params valueForKey:key] isKindOfClass:[NSData class]])) {
				[dataDictionary setObject:[params valueForKey:key] forKey:key];
				continue;
			}
			[GTaoBaoRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, [params valueForKey:key]]];
			[GTaoBaoRequest appendUTF8Body:body dataString:bodyPrefixString];
		}
		if ([dataDictionary count] > 0) {
			for (id key in dataDictionary) {
				NSObject *dataParam = [dataDictionary valueForKey:key];
				if ([dataParam isKindOfClass:[UIImage class]]) {
					NSData* imageData = UIImagePNGRepresentation((UIImage *)dataParam);
					[GTaoBaoRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.png\"\r\n", key]];
					[GTaoBaoRequest appendUTF8Body:body dataString:[NSString stringWithString:@"Content-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"]];
					[body appendData:imageData];
				} 
				else if ([dataParam isKindOfClass:[NSData class]]) {
                    [GTaoBaoRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"*.*\"\r\n", key]];
					[GTaoBaoRequest appendUTF8Body:body dataString:[NSString stringWithString:@"Content-Type: */*\r\nContent-Transfer-Encoding: binary\r\n\r\n"]];
					[body appendData:(NSData*)dataParam];
				}
				[GTaoBaoRequest appendUTF8Body:body dataString:bodySuffixString];
			}
		}
    }
    return body;
}

- (void)handleResponseData:(NSData *)data {
	NSError* error = nil;
	id result = [self parseJSONData:data error:&error];
	if (error) {
		[self failedWithError:error];
	} 
	else {
        if ([delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)]) {
            [delegate request:self didFinishLoadingWithResult:(result == nil ? data : result)];
		}
	}
}

- (id)parseJSONData:(NSData *)data error:(NSError **)error {
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	SBJSON *jsonParser = [[SBJSON alloc]init];
	NSError *parseError = nil;
	id result = [jsonParser objectWithString:dataString error:&parseError];
	if (parseError) {
        if (error != nil) {
            *error = [self errorWithCode:kGTErrorCodeSDK
                                userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kGTSDKErrorCodeParseError] forKey:kGTSDKErrorCodeKey]];
        }
	}
	[dataString release];
	[jsonParser release];
	
	if ([result isKindOfClass:[NSDictionary class]]) {
		if ([result objectForKey:@"error_code"] != nil && [[result objectForKey:@"error_code"] intValue] != 200) {
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
+ (GTaoBaoRequest *)requestWithURL:(NSString *)url 
                   httpMethod:(NSString *)httpMethod 
                       params:(NSDictionary *)params
                 postDataType:(GTaoBaoRequestPostDataType)postDataType
             httpHeaderFields:(NSDictionary *)httpHeaderFields
                     delegate:(id<GTaoBaoRequestDelegate>)delegate {
    
    GTaoBaoRequest *request = [[[GTaoBaoRequest alloc] init] autorelease];
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.postDataType = postDataType;
    request.httpHeaderFields = httpHeaderFields;
    request.delegate = delegate;
    return request;
}

+ (GTaoBaoRequest *)requestWithAccessToken:(NSString *)accessToken
                                  url:(NSString *)url
                           httpMethod:(NSString *)httpMethod 
                               params:(NSDictionary *)params
                         postDataType:(GTaoBaoRequestPostDataType)postDataType
                     httpHeaderFields:(NSDictionary *)httpHeaderFields
                             delegate:(id<GTaoBaoRequestDelegate>)delegate {
    // add the access token field
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParams setObject:accessToken forKey:@"access_token"];
    return [GTaoBaoRequest requestWithURL:url
                          httpMethod:httpMethod
                              params:mutableParams
                        postDataType:postDataType 
                    httpHeaderFields:httpHeaderFields
                            delegate:delegate];
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod {
    if (![httpMethod isEqualToString:@"GET"]) {
        return baseURL;
    }
    
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
	NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString *query = [GTaoBaoRequest stringFromDictionary:params];
	
	return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

- (void)connect {
    NSString *urlString = [GTaoBaoRequest serializeURL:url params:params httpMethod:httpMethod];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:kGTaoBaoRequestTimeOutInterval];
    [request setHTTPMethod:httpMethod];
    if ([httpMethod isEqualToString:@"POST"]) {
        if (postDataType == kGTaoBaoRequestPostDataTypeMultipart) {
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kGTaoBaoRequestStringBoundary];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
        
        [request setHTTPBody:[self postBody]];
    }
    
    for (NSString *key in [httpHeaderFields keyEnumerator]) {
        [request setValue:[httpHeaderFields objectForKey:key] forHTTPHeaderField:key];
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
