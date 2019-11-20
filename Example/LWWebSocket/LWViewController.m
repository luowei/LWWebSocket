//
//  LWViewController.m
//  LWWebSocket
//
//  Created by luowei on 11/19/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import "LWViewController.h"
#import <LWWebSocket/WebSocketManager.h>
#import <View+MASAdditions.h>
#import <WebKit/WebKit.h>

@interface LWViewController (){
    WKWebView *_webView;
}

@end

@implementation LWViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
    [self.view addSubview:_webView];

    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];

    NSBundle *bundle =  [NSBundle bundleWithPath:[[NSBundle bundleForClass:[WebSocketManager class]] pathForResource:@"LWWebSocket" ofType:@"bundle"]];
    NSString *path = [bundle pathForResource:@"index" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    [_webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
    [_webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://localhost"]];


}


@end
