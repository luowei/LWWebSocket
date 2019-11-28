//
//  WebSocketManager.h
//  YYMobileCore
//
//  Created by liusilan on 2017/4/7.
//  Copyright © 2017年 YY.inc. All rights reserved.
//

#ifdef DEBUG
#define WSLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define WSLog(...)
#endif

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(uint32_t, LWSocketMessageType) {
    SocketMessageType_Raw = 0,
    SocketMessageType_Hello = 1,
    SocketMessageType_HeartBeat = 2,
    SocketMessageType_StreamStart = 3,
    SocketMessageType_Streaming = 4,
    SocketMessageType_StreamEnd = 5,
    SocketMessageType_String = 6,
    SocketMessageType_Data = 7,
};

@interface WebSocketManager : NSObject

@property(nonatomic, copy) void (^handleReceiveMessage)(uint32_t messageType,NSString *message);

@property(nonatomic, copy) void (^handleReceiveData)(uint32_t messageType,NSData *data);

+ (instancetype)sharedManager;
- (void)startServerWithPort:(UInt16)port webPath:(NSString *)webPath;
- (void)stopServer;

-(BOOL)sendMessage:(NSString *)message;
-(BOOL)sendData:(NSData *)data;
-(BOOL)sendDataWithFileURL:(NSURL *)fileURL;

@end
