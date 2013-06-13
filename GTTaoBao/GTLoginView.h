//
//  GTLoginView.h
//  PocoCamera2
//
//  Created by GTL on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GTHeader.h"

@class GTLoginView;

@protocol GTLoginViewDelegate <NSObject>
@optional
- (void)authorizeWebView:(GTLoginView *)webView didReceiveString:(NSString *)string;
- (void)authorizeWebView:(GTLoginView *)webView cancel:(BOOL)cancel;

@end

@interface GTLoginView : UIView <UIWebViewDelegate> {
    id<GTLoginViewDelegate> delegate;
    UIWebView *webView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
    BOOL http_responed;
}

@property (nonatomic, assign) id<GTLoginViewDelegate> delegate;

- (void)loadBarWithString:(NSString *)aString;
- (void)loadRequestWithURL:(NSURL *)url;
- (void)showLoginView:(BOOL)animated;
- (void)hideLoginView:(BOOL)animated;

@end
