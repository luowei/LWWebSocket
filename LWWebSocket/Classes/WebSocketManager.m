//
//  WebSocketManager.m
//  YYMobileCore
//
//  Created by liusilan on 2017/4/7.
//  Copyright © 2017年 YY.inc. All rights reserved.
//

#import "WebSocketManager.h"
#import "HTTPConnection.h"
#import "HTTPServer.h"
#import "WebSocket.h"



@class MyWebSocket;

@interface WebSocketManager ()<WebSocketDelegate>
@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, weak) MyWebSocket *webSocket;

@property(nonatomic, strong) NSOutputStream *dataStream;
@property(nonatomic, copy) NSString *streamFilePath;
@property(nonatomic, strong) NSError *streamError;
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

-(NSString *)streamFilePath {
    if(!_streamFilePath){
        _streamFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
    }
    return _streamFilePath;
}

-(NSOutputStream *)dataStream {
    if(!_dataStream){
        _dataStream = [[NSOutputStream alloc] initToFileAtPath:self.streamFilePath append:YES];
    }
    return _dataStream;
}

- (void)startServerWithPort:(UInt16)port webPath:(NSString *)webPath {
    
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
    [_httpServer setPort:port];

    //NSString *webPath = NSHomeDirectory();
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *absWebPath = documentPath;
    if(![webPath hasPrefix:@"/var"]){
        absWebPath = [documentPath stringByAppendingPathComponent:webPath];
    }else{
        absWebPath = webPath;
    }
    BOOL isDirectory = NO;
    BOOL existWebPath = [NSFileManager.defaultManager fileExistsAtPath:absWebPath isDirectory:&isDirectory];
    if(!isDirectory || !existWebPath) { //文件夹不存在
        NSError *error;
        BOOL success = [NSFileManager.defaultManager createDirectoryAtPath:absWebPath withIntermediateDirectories:YES attributes:nil error:&error];
        WSLog(@"success = %d，error = %@", success,error);
        absWebPath = success ? absWebPath : documentPath;
    }

    [_httpServer setDocumentRoot:absWebPath];

    WSLog(@"=====webpath:%@",webPath);

    // Start the server (and check for problems)
    
    NSError *error;
    if(![_httpServer start:&error]) {
        WSLog(@"start server error:%@", error.localizedDescription);
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

-(BOOL)sendMessage:(NSString *)message {
    if(!self.webSocket){
        return NO;
    }

    [self.webSocket sendMessage:message];

    return YES;
}

-(BOOL)sendData:(NSData *)data {
    if(!self.webSocket){
        return NO;
    }

    NSMutableData *sendData = [self constructDataWithMessageType:SocketMessageType_Data];
    [sendData appendData:data];
    [self.webSocket sendData:sendData isBinary:YES];

    return YES;
}

-(BOOL)sendDataWithFileURL:(NSURL *)fileURL {
    if(!self.webSocket){
        return NO;
    }

    NSMutableData *startData = [self constructDataWithMessageType:SocketMessageType_StreamStart];
    [self.webSocket sendData:startData isBinary:YES];

    NSError *error;
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
    if(error){
        WSLog(@"===error:%@",error.localizedDescription);
    }
    NSData * data = nil;
    while ((data = [fileHandle readDataOfLength:10240])) {
        if(data.length > 0){
            NSMutableData *streamingData = [self constructDataWithMessageType:SocketMessageType_Streaming];
            [streamingData appendData:data];
            [self.webSocket sendData:streamingData isBinary:YES];
        }else{
            break;
        }
    }
/*
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:filePath];
    uint8_t buffer[10240];
    int len = 0;
    while ([inputStream hasBytesAvailable]) {
        len = [inputStream read:buffer maxLength:sizeof(buffer)];
        if (len > 0) {
            NSMutableData *streamingData = [self constructDataWithMessageType:SocketMessageType_Streaming];
            [streamingData appendBytes:buffer length:(NSUInteger)len];
            [self.webSocket sendData:streamingData isBinary:YES];
        }
    }
*/

    NSMutableData *endData = [self constructDataWithMessageType:SocketMessageType_StreamEnd];
    [self.webSocket sendData:endData isBinary:YES];

    return YES;
}


//构造数据头部
- (NSMutableData *)constructDataWithMessageType:(uint32_t)messageType {
    NSMutableData *data = [NSMutableData dataWithCapacity:0];
    [data appendBytes:&messageType length:sizeof(uint32_t)];
    return data;
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
    WSLog(@"=======%s", __FUNCTION__);

    if([ws isKindOfClass:[MyWebSocket class]]){
        self.webSocket = (MyWebSocket *)ws;
    }
    [self.webSocket startHeartBeatRecvTimer];

    [self sendActiveBinaryData];
}

//收到消息串
- (void)webSocket:(WebSocket *)ws didReceiveMessage:(NSString *)msg{
    WSLog(@"=======%s", __FUNCTION__);
    MyWebSocket *webSocket = (MyWebSocket *)ws;

    if (msg.length <= 0) {
        return;
    }

    WSLog(@"=======didReceiveMessage msg:%@", msg);

    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return;
    }

    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    uint32_t messageType = (uint32_t)[dict[@"messageType"] integerValue];
    if(messageType == SocketMessageType_HeartBeat){
        [webSocket startHeartBeatRecvTimer];
        return;
    }

    NSString *messageBody = dict[@"messageBody"];

    //处理msg
    if(self.handleReceiveMessage){
        self.handleReceiveMessage(messageType,messageBody);
    }

/*
    NSString *messageType = dict[@"messageType"];
    if (messageType.length <= 0) {
        return;
    }

    if ([messageType isEqualToString:@"heartBeat"]) {
        [webSocket startHeartBeatRecvTimer];
        return;
    }
*/

}

//收到二进制数据
- (void)webSocket:(WebSocket *)ws didReceiveData:(NSData *)data{
    WSLog(@"=======%s",__FUNCTION__);
    MyWebSocket *webSocket = (MyWebSocket *)ws;
    if(!self.handleReceiveData){
        return;
    }

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

    //处理data，第4个字节之后为真实数据
    NSData *realData = [data subdataWithRange:NSMakeRange(headerLen, data.length - headerLen)];

    switch (messageType) {
        case SocketMessageType_StreamStart: {
            WSLog(@"======ws didReceiveData StreamStart");
            [self.dataStream open];
            self.handleReceiveData(messageType, nil);
            break;
        }
        case SocketMessageType_Streaming: {
            WSLog(@"======ws didReceiveData Streaming ...");
            NSUInteger dataLength = [realData length];
            NSInteger writeLen = [self.dataStream write:[realData bytes] maxLength:dataLength];
            if(dataLength > writeLen){  //发生错误
                self.streamFilePath = nil;
                self.streamError = [self.dataStream streamError];
                [self.dataStream close];
                self.dataStream = nil;
                return;
            }
            self.handleReceiveData(messageType, nil);
            break;
        }
        case SocketMessageType_StreamEnd: {
            WSLog(@"======ws didReceiveData StreamEnd");
            if(self.dataStream && self.dataStream.streamStatus != NSStreamStatusClosed){
                [self.dataStream close];
                self.dataStream = nil;
            }
            NSData *pathData = self.streamError==nil ?[self.streamFilePath dataUsingEncoding:NSUTF8StringEncoding] : nil;
            self.handleReceiveData(messageType, pathData);
            break;
        }
        default: {
            self.handleReceiveData(messageType, realData);
            break;
        }
    }
}

//websocket链接关闭
- (void)webSocketDidClose:(WebSocket *)ws{
    WSLog(@"=======%s",__FUNCTION__);
//    [self.webSocket stop];
//    self.webSocket = nil;
}



@end
