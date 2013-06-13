//
//  GTaoBaoLoginView.h
//  PocoCamera2
//
//  Created by GTL on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GTaoBaoHeader.h"

@class GTaoBaoLoginView;

@protocol GTaoBaoLoginViewDelegate <NSObject>
@optional
- (void)authorizeWebView:(GTaoBaoLoginView *)webView didReceiveString:(NSString *)string;
- (void)authorizeWebView:(GTaoBaoLoginView *)webView cancel:(BOOL)cancel;

@end

@interface GTaoBaoLoginView : UIView <UIWebViewDelegate> {
    id<GTaoBaoLoginViewDelegate> delegate;
    UIWebView *webView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
}

@property (nonatomic, assign) id<GTaoBaoLoginViewDelegate> delegate;

- (void)loadBarWithString:(NSString *)aString;
- (void)loadRequestWithURL:(NSURL *)url;
- (void)showLoginView:(BOOL)animated;
- (void)hideLoginView:(BOOL)animated;

@end
