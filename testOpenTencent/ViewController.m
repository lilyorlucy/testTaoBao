//
//  ViewController.m
//  testOpenTencent
//
//  Created by admin on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "GTaoBaoEngine.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIButton *loginQQ = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    loginQQ.backgroundColor = [UIColor redColor];
    [loginQQ addTarget:self action:@selector(loginQQ:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginQQ];
    [loginQQ release];
    
    UIButton *sendWeibo = [[UIButton alloc] initWithFrame:CGRectMake(0, 150, 100, 100)];
    sendWeibo.backgroundColor = [UIColor blackColor];
    [sendWeibo addTarget:self action:@selector(getUserInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendWeibo];
    [sendWeibo release];
    
    taobao = [[GTaoBaoEngine alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(IBAction)loginQQ:(id)sender {
    [taobao logIn];
}

-(IBAction)getUserInfo:(id)sender {
    [taobao getUserInfo];
}

@end
