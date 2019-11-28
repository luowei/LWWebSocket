//
//  KeyboardViewController.m
//  XXKeyboard
//
//  Created by luowei on 2019/11/27.
//  Copyright © 2019 luowei. All rights reserved.
//

#import "KeyboardViewController.h"
#import "LWWebLoader.h"

@interface KeyboardViewController ()
@property(nonatomic, strong) UIButton *nextKeyboardButton;
@property(nonatomic, strong) UIButton *lexiconBtn;
@property(nonatomic, strong) UIButton *getBtn;

@property(nonatomic, strong) LWWebLoader *webloader;
@property(nonatomic, strong) LWWebLoader *wsWebloader;
@property(nonatomic, strong) UIButton *conwsBtn;
@property(nonatomic, strong) UIButton *sendWSBtn;
@property(nonatomic, strong) UIButton *webViewBtn;
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];

    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];



    // Perform custom UI setup here
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextKeyboardButton setTitle:@"下一步" forState:UIControlStateNormal];
    [self.nextKeyboardButton addTarget:self action:@selector(handleInputModeListFromView:withEvent:) forControlEvents:UIControlEventAllTouchEvents];
    [self.view addSubview:self.nextKeyboardButton];

    [self.nextKeyboardButton sizeToFit];
    self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.nextKeyboardButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.nextKeyboardButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;


    self.lexiconBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.lexiconBtn setTitle:@"Lexicon" forState:UIControlStateNormal];
    [self.lexiconBtn addTarget:self action:@selector(lexiconBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.lexiconBtn];

    [self.lexiconBtn sizeToFit];
    self.lexiconBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.lexiconBtn.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:30].active = YES;
    [self.lexiconBtn.bottomAnchor constraintEqualToAnchor:self.view.topAnchor constant:30].active = YES;


    self.getBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.getBtn setTitle:@"GetData" forState:UIControlStateNormal];
    [self.getBtn addTarget:self action:@selector(getBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.getBtn];

    [self.getBtn sizeToFit];
    self.getBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.getBtn.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:120].active = YES;
    [self.getBtn.bottomAnchor constraintEqualToAnchor:self.view.topAnchor constant:30].active = YES;


    //链接WSWebView
    self.webViewBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.webViewBtn setTitle:@"构建WSWebView" forState:UIControlStateNormal];
    [self.webViewBtn addTarget:self action:@selector(webViewBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.webViewBtn];

    [self.webViewBtn sizeToFit];
    self.webViewBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.webViewBtn.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:30].active = YES;
    [self.webViewBtn.bottomAnchor constraintEqualToAnchor:self.view.topAnchor constant:80].active = YES;


    //链接WebSocket
    self.conwsBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.conwsBtn setTitle:@"连接WS" forState:UIControlStateNormal];
    [self.conwsBtn addTarget:self action:@selector(conwsBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.conwsBtn];

    [self.conwsBtn sizeToFit];
    self.conwsBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.conwsBtn.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:180].active = YES;
    [self.conwsBtn.bottomAnchor constraintEqualToAnchor:self.view.topAnchor constant:80].active = YES;

    
    //发送数据到宿主APP
    self.sendWSBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendWSBtn setTitle:@"发送WS" forState:UIControlStateNormal];
    [self.sendWSBtn addTarget:self action:@selector(sendWSBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendWSBtn];

    [self.sendWSBtn sizeToFit];
    self.sendWSBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sendWSBtn.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:260].active = YES;
    [self.sendWSBtn.bottomAnchor constraintEqualToAnchor:self.view.topAnchor constant:80].active = YES;

    
}

-(void)lexiconBtnAction {
    NSMutableDictionary *myLexicon = @{}.mutableCopy;
    [self requestSupplementaryLexiconWithCompletion:^(UILexicon *lexicon) {
        NSArray<UILexiconEntry *> *entries = lexicon.entries;
        for(UILexiconEntry *item in entries){
            myLexicon[item.userInput] = item.documentText;
            NSLog(@"=======item.userInput:%@ \t item.documentText:%@",item.userInput,item.documentText);
        }
    }];
}


#pragma mark - WKWebView Turnner

-(LWWebLoader *)webloader {
    _webloader = LWWebLoader.webloader;
    return _webloader;
}

- (void)getBtnAction {
    NSString *urlString = @"http://mytest.com/test.json";
//    NSString *urlString = @"http://mytest.com/mitm.html";
//    NSString *urlString = @"http://mytest.com/DeepRPC.zip";
//    NSString *urlString = @"http://wodedata.com/MyResource/MyInputMethod/App/OtherVC_v14.json";

    WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString method:GetData methodArguments:nil userAgent:nil contentType:nil postData:nil uploadData:nil];
    __weak typeof(self) weakSelf = self;
    [self.webloader evaluateWithBody:evaluateBody parentView:self.view dataLoadCompletionHandler:^(WLHanderBody *body,NSError *error){
        if (error) {
            NSLog(@"======error:%@\n", error);
            return;
        }

        [weakSelf handleWithBody:body];
    }];
}

- (void)handleWithBody:(WLHanderBody *)body {
    switch (body.bodyType) {
        case BodyType_Error: {
            NSLog(@"======error:%@\n", body.handlerResult);
            break;
        }
        case BodyType_Json: {
            NSLog(@"==========handlerBody json:%@", body.handlerResult);
            break;
        }
        case BodyType_PlainText: {
            NSLog(@"==========handlerBody text:%@", body.handlerResult);
            break;
        }
        case BodyType_Data: {
            [self writeToFileWithData:body.handlerResult];
            break;
        }
        case BodyType_StreamStart: {
            NSLog(@"==========stream start:%@", body.handlerResult);
            break;
        }
        case BodyType_Streaming: {
            NSLog(@"==========streaming :%.2f ...", [body.handlerResult doubleValue]);
            break;
        }
        case BodyType_StreamEnd: {
            NSLog(@"==========streamed file path:%@", body.handlerResult);
            break;
        }
        case BodyType_WSOpened:{
            NSLog(@"==========ws opened ! ");
            break;
        }
        case BodyType_WSClosed:{
            NSLog(@"==========ws closed ! ");
            break;
        }
        default: {
            break;
        }
    }
}

- (void)writeToFileWithData:(NSData *)data {
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"aaaa.zip"];
    NSError *err;
    [(NSData *)data writeToFile:filePath options:NSDataWritingAtomic error:&err];
    if(err){
        NSLog(@"==========下载完成，但保存文件失败");
    }else{
        NSLog(@"==========下载完成，文件保存在:%@", filePath);
    }
}


#pragma mark - WebSocket Turnner

-(LWWebLoader *)wsWebloader {
    if(!_webloader){
        _webloader = LWWebLoader.webloader;
    }
    return _webloader;
}

-(void)webViewBtnAction {

    void (^receiveWSDataHandler)(WLHanderBody *_Nonnull, NSError *) = ^(WLHanderBody *body,NSError *error){
        switch (body.bodyType) {
            case BodyType_Error: {
                NSLog(@"======ws error:%@\n", body.handlerResult);
                break;
            }
            case BodyType_PlainText: {
                NSLog(@"==========ws handlerBody text:%@", body.handlerResult);
                break;
            }
            case BodyType_Data: {
                NSString *dataString = [[NSString alloc] initWithData:body.handlerResult encoding:NSUTF8StringEncoding];
                NSLog(@"==========ws data:%@", dataString);
//                [self writeToFileWithData:body.handlerResult];
                break;
            }
            case BodyType_StreamStart: {
                NSLog(@"==========ws stream start:%@", body.handlerResult);
                break;
            }
            case BodyType_Streaming: {
                NSLog(@"==========ws streaming  ...");
                break;
            }
            case BodyType_StreamEnd: {
                NSLog(@"==========ws streamed file path:%@", body.handlerResult);
                break;
            }
            case BodyType_WSOpened:{
                NSLog(@"==========ws opened ! ");
                break;
            }
            case BodyType_WSClosed:{
                NSLog(@"==========ws closed ! ");
                break;
            }
            default: {
                break;
            }
        }
    };

    [self.wsWebloader startWSWebViewWithParentView:self.view receiveWSDataHandler:receiveWSDataHandler];
}
-(void)conwsBtnAction {
    [self.wsWebloader wsConnect];
}

-(void)sendWSBtnAction {
//    NSData *data = [@"aaaaa" dataUsingEncoding:NSUTF8StringEncoding];
//    [self.wsWebloader wsSendData:data];

//    NSString *message = @"Welcome WebSocket Zone!";
//    [self.wsWebloader wsSendString:message];

    NSBundle *bundle =  ([NSBundle bundleWithPath:[[NSBundle bundleForClass:[self.wsWebloader class]] pathForResource:@"LWWebLoader" ofType:@"bundle"]] ?: ([NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"WLWebLoader " ofType:@"bundle"]] ?: [NSBundle mainBundle]));
    NSURL *fileURL = [bundle URLForResource:@"aaaa" withExtension:@"zip"];

    //发送文件
    [self.wsWebloader wsSendStreamStart];

    NSError *error;
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
    if(error){
        NSLog(@"===error:%@",error.localizedDescription);
    }
    NSData * data = nil;
    while ((data = [fileHandle readDataOfLength:1024*10])) {
        if(data.length > 0){
            [self.wsWebloader wsSendStreaming:data];
        }else{
            break;
        }
    }

    [self.wsWebloader wsSendStreamEnd];
}



- (void)viewWillLayoutSubviews {
    self.nextKeyboardButton.hidden = !self.needsInputModeSwitchKey;
    [super viewWillLayoutSubviews];
}

- (void)textWillChange:(id <UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id <UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.

    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

@end
