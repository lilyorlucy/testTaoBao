//
//  GTaoBaoLoginView.m
//  PocoCamera2
//
//  Created by GTL on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTaoBaoLoginView.h"

@implementation GTaoBaoLoginView

@synthesize delegate;

#pragma mark -
#pragma mark Cycle
- (id)init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 480)])
    {
        [self loadBarWithString:SHARENAME];
        [self setBackgroundColor:[UIColor clearColor]];
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, 320, 435)];
        [self addSubview:containerView];
        [containerView release];
        
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 435)];
		[webView setDelegate:self];
		[containerView addSubview:webView];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView setCenter:CGPointMake(160, 215)];
        [containerView addSubview:indicatorView];
        [indicatorView release];
    }
    return self;
}

- (void)loadBarWithString:(NSString *)aString {
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    topBar.backgroundColor = [UIColor clearColor];
    [self addSubview:topBar];
    
    UIImageView *topbarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    topbarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"green_bar.png"]];
    [topBar addSubview:topbarView];
    [topbarView release];
    
    UILabel *topbarWord = [[UILabel alloc] initWithFrame:CGRectMake(5, 4, 315, 45)];
    topbarWord.center = topBar.center;
    topbarWord.backgroundColor = [UIColor clearColor];
    topbarWord.text = aString;
    topbarWord.textColor = [UIColor whiteColor];
    topbarWord.textAlignment = UITextAlignmentCenter;
    topbarWord.font = [UIFont boldSystemFontOfSize:17];
    [topBar addSubview:topbarWord];
    [topbarWord release];
    
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 1.5, 108/2, 88/2)];
    [homeButton setImage:[UIImage imageNamed:@"green_setting_back_n.png"] forState:UIControlStateNormal];
    [homeButton setImage:[UIImage imageNamed:@"green_setting_back_l.png"] forState:UIControlStateHighlighted];
    [homeButton addTarget:self action:@selector(onCloseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:homeButton];
    [homeButton release];
    
    [topBar release];
}

- (void)dealloc {
    [webView release], webView = nil;
    webView.delegate = nil;
    [super dealloc];
}

#pragma mark Actions
- (void)onCloseButtonTouched:(id)sender
{
    [self hideLoginView:YES];
    [self.delegate authorizeWebView:self cancel:YES];
}

#pragma mark -
#pragma mark Public Methods
- (void)loadRequestWithURL:(NSURL *)url {
    NSURLRequest *request =[NSURLRequest requestWithURL:url
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [webView loadRequest:request];
}

- (void)showLoginView:(BOOL)animated {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
  	[[window rootViewController].view addSubview:self];
    
    if (animated) {
        NSLog(@"fram:%f, %f", self.frame.origin.x, self.frame.origin.y);
        [self setFrame:CGRectMake(0, 480, self.frame.size.width, self.frame.size.height)];
        NSLog(@"fram:%f, %f", self.frame.origin.x, self.frame.origin.y);
        CGAffineTransform transform = CGAffineTransformIdentity;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [self setTransform:CGAffineTransformTranslate(transform, 0, -480)];
        [UIView commitAnimations];
    }
}

- (void)hideLoginView:(BOOL)animated {
	if (animated) {
        CGAffineTransform transform = CGAffineTransformIdentity;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounceOutAnimationStopped)];
        [self setTransform:CGAffineTransformTranslate(transform, 0, 480)];
        [UIView commitAnimations];
	} else {
        [self removeFromSuperview];
    }
}

- (void)bounceOutAnimationStopped {
    [self removeFromSuperview];
}

#pragma mark -
#pragma mark UIWebViewDelegate Methods
- (void)webViewDidStartLoad:(UIWebView *)aWebView {
	[indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
    [indicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"URL:%@", request.URL.absoluteString);
    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
    if (range.location != NSNotFound) {
        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
         NSRange range2 = [code rangeOfString:@"&"];
        if (range2.location != NSNotFound) {
            code = [code substringToIndex:range2.location];
        }
        NSLog(@"code:%@", code);
        if ([delegate respondsToSelector:@selector(authorizeWebView:didReceiveString:)]) {
            [delegate authorizeWebView:self didReceiveString:code];
        }
    }
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
