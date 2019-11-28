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
#import <SafariServices/SafariServices.h>

@interface LWViewController ()<SFSafariViewControllerDelegate> {
    WKWebView *_webView;
}

@end

@implementation LWViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *btn01 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:btn01];
    [btn01 addTarget:self action:@selector(btn01Action) forControlEvents:UIControlEventTouchUpInside];
    [btn01 setTitle:@"打开网页" forState:UIControlStateNormal];
    [btn01 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(-120);
        make.top.equalTo(self.view).offset(80);
    }];

    UIButton *btn02 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:btn02];
    [btn02 addTarget:self action:@selector(btn02Action:) forControlEvents:UIControlEventTouchUpInside];
    [btn02 setTitle:@"打开WSServer" forState:UIControlStateNormal];
    [btn02 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(80);
    }];

    UIButton *btn03 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:btn03];
    [btn03 addTarget:self action:@selector(btn03Action) forControlEvents:UIControlEventTouchUpInside];
    [btn03 setTitle:@"加载WebView" forState:UIControlStateNormal];
    [btn03 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(120);
        make.top.equalTo(self.view).offset(80);
    }];


    UITextField *textField = [UITextField new];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = @"请输入";
    textField.frame = CGRectMake(20, 30, 335, 40);
    [self.view addSubview:textField];



    [WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType,NSString *message){

        switch (messageType){
            case SocketMessageType_String:{
                //todo:
                break;
            }
            case SocketMessageType_Raw:{
                //todo:
                break;
            }
            default:{
                break;
            }
        }

    };

    [WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType,NSData *data){
        switch (messageType){
            case SocketMessageType_StreamStart:{
                //todo:
                break;
            }
            case SocketMessageType_Streaming:{
                break;
            }
            case SocketMessageType_StreamEnd:{
                break;
            }
            case SocketMessageType_Data:{
                //处理接收到的二进制数据
                NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"messageType:%d,text:%@", messageType, text);
                break;
            }
            case SocketMessageType_Raw:{
                break;
            }
            default:{
                break;
            }
        }

    };

}

- (void)loadWSWebView {
    if(!_webView){
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
        [self.view addSubview:_webView];

        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(160, 0, 0, 0));
        }];
    }
    NSBundle *bundle =  [NSBundle bundleWithPath:[[NSBundle bundleForClass:[WebSocketManager class]] pathForResource:@"LWWebSocket" ofType:@"bundle"]];
    NSString *path = [bundle pathForResource:@"index" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    [_webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
    [_webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://localhost"]];
}

- (void)btn01Action {
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"http://localhost:12345"] entersReaderIfAvailable:YES];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:YES completion:nil];
}

- (void)btn02Action:(UIButton *)btn {
    NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    [[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];

    [WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType,NSString *message){

        switch (messageType){
            case SocketMessageType_String:{
                NSLog(@"handleReceiveMessage Type:%d,text:%@", messageType, message);
                break;
            }
            default:{
                break;
            }
        }

    };

    [WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType,NSData *data){
        switch (messageType){
            case SocketMessageType_StreamStart:{
                NSLog(@"handleReceiveMessage StreamStart");
                break;
            }
            case SocketMessageType_Streaming:{
                break;
            }
            case SocketMessageType_StreamEnd:{
                NSString *dataPath = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"handleReceiveMessage StreamEnd, dataPath:%@",dataPath);
                break;
            }
            case SocketMessageType_Data:{
                //处理接收到的二进制数据
                NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"handleReceiveData Type:%d,text:%@", messageType, text);
                break;
            }
            default:{
                break;
            }
        }

    };

    [btn setBackgroundColor:btn.selected ? UIColor.clearColor : UIColor.greenColor];

}

- (void)btn03Action {
    [self loadWSWebView];
}


@end
