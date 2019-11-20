//
//  WebSocketManager.m
//  YYMobileCore
//
//  Created by liusilan on 2017/4/7.
//  Copyright © 2017年 YY.inc. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "WebSocketManager.h"
#import "HTTPConnection.h"
#import "HTTPServer.h"
#import "WebSocket.h"


typedef NS_OPTIONS(uint32_t, LWSocketMessageType) {
    SocketMessageType_Raw = 0,
    SocketMessageType_Hello = 1,
    SocketMessageType_HeartBeat = 1 << 1,
    SocketMessageType_StreamStart = 1 << 2,
    SocketMessageType_Streaming = 1 << 3,
    SocketMessageType_StreamEnd = 1 << 4,
    SocketMessageType_String = 1 << 5,
    SocketMessageType_Data = 1 << 6,
};

@class MyWebSocket;

@interface WebSocketManager ()<WebSocketDelegate>
@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, weak) MyWebSocket *webSocket;
- (NSString *)myURI;
@end



@interface MyWebSocket : WebSocket
@property(nonatomic, copy) NSString *uri;
- (void)startHeartBeatRecvTimer;
@end

@implementation MyWebSocket{
    dispatch_source_t _heartBeatRecvTimer;
    dispatch_queue_t _heartBeatRecvQueue;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - heartBeat

// 心跳回包计时器
- (void)startHeartBeatRecvTimer {
    [self stopHeartBeatRecvTimer];

    __weak typeof(self) wself = self;
    if (!_heartBeatRecvQueue) {
        _heartBeatRecvQueue = dispatch_queue_create("com.wodedata.mobile.heatBeatRecv", DISPATCH_QUEUE_SERIAL);
    }

    _heartBeatRecvTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _heartBeatRecvQueue);
    dispatch_source_set_timer(_heartBeatRecvTimer, dispatch_walltime(NULL, 8 * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, (1ull * NSEC_PER_SEC) / 10);

    dispatch_source_set_event_handler(_heartBeatRecvTimer, ^{
        [wself timerHandle];
    });
    dispatch_resume(_heartBeatRecvTimer);
}

- (void)stopHeartBeatRecvTimer {

    if (_heartBeatRecvTimer) {
        dispatch_source_cancel(_heartBeatRecvTimer);
        _heartBeatRecvTimer = nil;
    }
}

// 超时未收到回包，关闭连接
- (void)timerHandle {
    [self stopHeartBeatRecvTimer];

    [self stop];
}

@end



#pragma mark - MyHTTPConnection

@interface MyHTTPConnection : HTTPConnection {
}
@property(nonatomic, strong) MyWebSocket *webSocket;
@end

@implementation MyHTTPConnection

- (WebSocket *)webSocketForURI:(NSString *)path {
    NSString *myURI = WebSocketManager.sharedManager.myURI;
    if ([path isEqualToString:myURI]) {
        self.webSocket = [[MyWebSocket alloc] initWithRequest:request socket:asyncSocket];
        self.webSocket.uri = path;
        self.webSocket.delegate = WebSocketManager.sharedManager;
        return self.webSocket;
    }

    return [super webSocketForURI:path];
}

@end




#pragma mark - WebSocketManager

@implementation WebSocketManager

+ (instancetype)sharedManager {
    static WebSocketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [WebSocketManager new];
    });
    
    return manager;
}

- (void)startServer {
    
    if (_httpServer.isRunning) {
        return;
    }
    
    _httpServer = [[HTTPServer alloc] init];
    
    // Tell server to use our custom MyHTTPConnection class.
    [_httpServer setConnectionClass:[MyHTTPConnection class] ];

    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [_httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [_httpServer setPort:12345];
    
    //	[httpServer setDocumentRoot:webPath];
    
    // Start the server (and check for problems)
    
    NSError *error;
    if(![_httpServer start:&error]) {
        NSLog(@"start server error:%@", error.localizedDescription);
    }
}

- (void)stopServer {

    if (_httpServer && _httpServer.isRunning) {
        [_httpServer stop];
    }
}

- (NSString *)myURI {
    return @"/service";
}

-(BOOL)sendDataWithFilePath:(NSString *)filePath {
    if(!self.webSocket){
        return NO;
    }

    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:filePath];
    uint8_t buffer[1024];
    int len = 0;
//    NSMutableString *total = [[NSMutableString alloc] init];

    while ([inputStream hasBytesAvailable]) {
        len = [inputStream read:buffer maxLength:sizeof(buffer)];
        if (len > 0) {
            NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger) len];
            [self.webSocket sendData:data isBinary:YES];
            //[total appendString:[[NSString alloc] initWithBytes:buffer length:(NSUInteger) len encoding:NSASCIIStringEncoding]];
        }
    }

    return YES;
}


//发送第一个活跃状态的二进制测试消息
- (void)sendActiveBinaryData {
    NSMutableData *data = [NSMutableData dataWithCapacity:0];

    uint32_t messageType = SocketMessageType_Hello;
    [data appendBytes:&messageType length:sizeof(uint32_t)];

    [data appendData:[@"hello world!" dataUsingEncoding:NSUTF8StringEncoding]];

    [self.webSocket sendData:data isBinary:YES];
}



#pragma mark - WebSocketDelegate

//连接打开
- (void)webSocketDidOpen:(WebSocket *)ws {
    NSLog(@"=======%s", __FUNCTION__);

    if([ws isKindOfClass:[MyWebSocket class]]){
        self.webSocket = (MyWebSocket *)ws;
    }
    [self.webSocket startHeartBeatRecvTimer];

    [self sendActiveBinaryData];
}

//收到消息串
- (void)webSocket:(WebSocket *)ws didReceiveMessage:(NSString *)msg{
    NSLog(@"=======%s", __FUNCTION__);

    MyWebSocket *webSocket = (MyWebSocket *)ws;

    if (msg.length <= 0) {
        return;
    }

    NSLog(@"=======didReceiveMessage msg:%@", msg);

    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    NSString *messageType = dict[@"messageType"];
    if (messageType.length <= 0) {
        return;
    }

    if ([messageType isEqualToString:@"heartBeat"]) {
        [webSocket startHeartBeatRecvTimer];
    }

/*
    uint32_t messageType = [dict[@"messageType"] toUInt32];
    switch (messageType){
        case SocketMessageType_HeartBeat:{
            [webSocket startHeartBeatRecvTimer];
            break;
        }
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
*/


}

//收到二进制数据
- (void)webSocket:(WebSocket *)ws didReceiveData:(NSData *)data{
    NSLog(@"=======%s",__FUNCTION__);

    NSUInteger headerLen = 4;
    if(data.length < headerLen){
        return; //消息不合法
    }

    NSData *headerData = [data subdataWithRange:NSMakeRange(0, headerLen)];
    if(headerData.length <= 0 ){
        return; //获取消息错误
    }

    //appid，截取前4个字节
    uint32_t messageType;
    [headerData getBytes:&messageType length:sizeof(uint32_t)];

/*
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
            break;
        }
        case SocketMessageType_Raw:{
            break;
        }

        default:{
            break;
        }
    }
*/


    //第4个字节之后为真实数据
    NSData *realData = [data subdataWithRange:NSMakeRange(headerLen, data.length - headerLen)];

    //处理接收到的二进制数据
    NSString *text = [[NSString alloc] initWithData:realData encoding:NSUTF8StringEncoding];

    NSLog(@"messageType:%d,text:%@", messageType, text);

}

//websocket链接关闭
- (void)webSocketDidClose:(WebSocket *)ws{
    NSLog(@"=======%s",__FUNCTION__);
}



@end
