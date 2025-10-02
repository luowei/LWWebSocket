# LWWebSocket

[![CI Status](https://img.shields.io/travis/luowei/LWWebSocket.svg?style=flat)](https://travis-ci.org/luowei/LWWebSocket)
[![Version](https://img.shields.io/cocoapods/v/LWWebSocket.svg?style=flat)](https://cocoapods.org/pods/LWWebSocket)
[![License](https://img.shields.io/cocoapods/l/LWWebSocket.svg?style=flat)](https://cocoapods.org/pods/LWWebSocket)
[![Platform](https://img.shields.io/cocoapods/p/LWWebSocket.svg?style=flat)](https://cocoapods.org/pods/LWWebSocket)

## 简介

LWWebSocket 是一个用于 iOS 应用内的轻量级 WebSocket 数据传输服务器。它基于 CocoaHTTPServer、CocoaAsyncSocket 和 CocoaLumberjack 构建，提供了简单易用的 API 来在应用内启动 WebSocket 服务器，实现应用与 Web 页面之间的实时双向通信。

## 主要特性

- 轻量级 WebSocket 服务器实现
- 支持文本消息和二进制数据传输
- 支持大文件流式传输
- 内置心跳检测机制，自动断开超时连接
- 支持多种消息类型（字符串、数据、流）
- 单例模式管理，使用简单
- 线程安全的实现
- 集成 HTTP 文件服务器功能

## 系统要求

- iOS 8.0 及以上版本
- Xcode 开发环境

## 安装方式

### CocoaPods

LWWebSocket 可通过 [CocoaPods](https://cocoapods.org) 进行安装。只需在 Podfile 中添加以下行：

```ruby
pod 'LWWebSocket'
```

然后运行：

```bash
pod install
```

## 核心架构

### 核心类

#### WebSocketManager

单例管理类，负责 WebSocket 服务器的启动、停止和消息收发。

**主要属性：**
- `handleReceiveMessage`: 接收文本消息的回调 block
- `handleReceiveData`: 接收二进制数据的回调 block

**主要方法：**
- `+ (instancetype)sharedManager`: 获取单例实例
- `- (void)startServerWithPort:webPath:`: 启动 WebSocket 服务器
- `- (void)stopServer`: 停止服务器
- `- (BOOL)sendMessage:`: 发送文本消息
- `- (BOOL)sendData:`: 发送二进制数据
- `- (BOOL)sendDataWithFileURL:`: 发送文件（流式传输）

### 消息类型

框架定义了以下消息类型（`LWSocketMessageType`）：

```objective-c
typedef NS_OPTIONS(uint32_t, LWSocketMessageType) {
    SocketMessageType_Raw = 0,          // 原始数据
    SocketMessageType_Hello = 1,        // 连接建立消息
    SocketMessageType_HeartBeat = 2,    // 心跳消息
    SocketMessageType_StreamStart = 3,  // 流传输开始
    SocketMessageType_Streaming = 4,    // 流传输中
    SocketMessageType_StreamEnd = 5,    // 流传输结束
    SocketMessageType_String = 6,       // 字符串消息
    SocketMessageType_Data = 7,         // 二进制数据
};
```

## 使用示例

### 基本使用

```objective-c
#import <LWWebSocket/WebSocketManager.h>

// 1. 启动 WebSocket 服务器
NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
[[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];

// 2. 设置文本消息接收回调
[WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType, NSString *message) {
    switch (messageType) {
        case SocketMessageType_String: {
            NSLog(@"收到文本消息 - Type:%d, text:%@", messageType, message);
            break;
        }
        default:
            break;
    }
};

// 3. 设置二进制数据接收回调
[WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType, NSData *data) {
    switch (messageType) {
        case SocketMessageType_StreamStart: {
            NSLog(@"开始接收流数据");
            break;
        }
        case SocketMessageType_Streaming: {
            // 正在接收流数据
            break;
        }
        case SocketMessageType_StreamEnd: {
            NSString *dataPath = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"流数据接收完成，文件路径:%@", dataPath);
            break;
        }
        case SocketMessageType_Data: {
            // 处理接收到的二进制数据
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"收到二进制数据 - Type:%d, text:%@", messageType, text);
            break;
        }
        default:
            break;
    }
};
```

### 发送消息

```objective-c
// 发送文本消息
[[WebSocketManager sharedManager] sendMessage:@"Hello WebSocket"];

// 发送二进制数据
NSData *data = [@"Binary Data" dataUsingEncoding:NSUTF8StringEncoding];
[[WebSocketManager sharedManager] sendData:data];

// 发送文件（流式传输）
NSURL *fileURL = [NSURL fileURLWithPath:@"/path/to/file"];
[[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];
```

### 在 WebView 中使用

```objective-c
// 加载包含 WebSocket 客户端的 HTML 页面
WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds
                                        configuration:[WKWebViewConfiguration new]];

NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[WebSocketManager class]]
                                            pathForResource:@"LWWebSocket" ofType:@"bundle"]];
NSString *path = [bundle pathForResource:@"index" ofType:@"html"];
NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

[webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://localhost"]];
```

### JavaScript 客户端示例

```javascript
// 连接 WebSocket 服务器
var socket = new WebSocket('ws://localhost:11335/service');

// 连接成功
socket.onopen = function(event) {
    console.log('WebSocket 连接成功');

    // 发送文本消息
    socket.send(JSON.stringify({
        messageType: 6,  // SocketMessageType_String
        messageBody: "Hello from JavaScript"
    }));
};

// 接收消息
socket.onmessage = function(event) {
    if (typeof event.data === 'string') {
        console.log('收到文本消息:', event.data);
    } else {
        console.log('收到二进制数据');
    }
};

// 连接关闭
socket.onclose = function(event) {
    console.log('WebSocket 连接关闭');
};

// 连接错误
socket.onerror = function(error) {
    console.error('WebSocket 错误:', error);
};

// 发送心跳（保持连接）
setInterval(function() {
    if (socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({
            messageType: 2,  // SocketMessageType_HeartBeat
            messageBody: ""
        }));
    }
}, 5000);
```

## 高级特性

### 心跳机制

框架内置了心跳检测机制，用于保持连接活跃并及时断开失效连接：

- 服务器在连接建立后会启动心跳接收计时器
- 客户端需要每 5 秒发送一次心跳消息（messageType = 2）
- 如果 8 秒内未收到心跳回包，服务器将自动关闭连接
- 心跳消息格式：`{"messageType": 2, "messageBody": ""}`

### 流式传输

支持大文件的流式传输，避免内存占用过大：

**发送端（iOS）：**
```objective-c
NSURL *fileURL = [NSURL fileURLWithPath:filePath];
[[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];
```

**接收端处理：**
```objective-c
[WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType, NSData *data) {
    switch (messageType) {
        case SocketMessageType_StreamStart:
            // 开始接收流，可以创建输出流
            break;
        case SocketMessageType_Streaming:
            // 接收数据块，写入文件
            break;
        case SocketMessageType_StreamEnd:
            // 接收完成，data 包含保存的文件路径
            NSString *filePath = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            break;
    }
};
```

流式传输特点：
- 自动分块传输，每次读取 10KB
- 服务端自动管理临时文件存储
- 传输完成后返回文件路径
- 异常处理机制，传输失败自动清理

### 文件服务器

WebSocket 服务器同时提供 HTTP 文件服务功能：

```objective-c
// 设置文档根目录
NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
[[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];

// 通过浏览器访问：http://localhost:11335/filename.txt
```

支持的功能：
- 静态文件访问
- 目录浏览
- 自动创建不存在的目录
- 支持相对路径和绝对路径

## 技术实现

### 依赖库

1. **CocoaHTTPServer**: 提供 HTTP 服务器和 WebSocket 协议支持
2. **CocoaAsyncSocket**: 提供异步 Socket 通信能力
3. **CocoaLumberjack**: 提供日志记录功能

### 线程安全

- 所有 WebSocket 操作都在专用的 GCD 队列中执行
- 公共 API 方法都是线程安全的
- 回调 block 在主队列执行，方便 UI 更新

### 内存管理

- 使用单例模式管理 WebSocket 连接
- 弱引用 WebSocket 实例，避免循环引用
- 流式传输使用临时文件，避免大数据内存占用
- 自动清理失效连接和临时文件

## 调试与日志

框架提供了调试日志宏，仅在 DEBUG 模式下输出：

```objective-c
#ifdef DEBUG
#define WSLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define WSLog(...)
#endif
```

日志内容包括：
- 连接建立和关闭
- 消息收发
- 流传输状态
- 错误信息

## 示例项目

要运行示例项目：

1. 克隆仓库到本地
2. 进入 Example 目录
3. 运行 `pod install`
4. 打开 `LWWebSocket.xcworkspace`
5. 运行项目

示例项目包含：
- WebSocket 服务器启动/停止
- 消息收发演示
- WebView 集成示例
- 文件传输示例

## 常见问题

### Q: 如何修改 WebSocket 连接路径？

A: 默认连接路径为 `/service`，可在 `WebSocketManager.m` 中修改 `myURI` 方法：

```objective-c
- (NSString *)myURI {
    return @"/service";  // 修改为您需要的路径
}
```

### Q: 为什么连接会自动断开？

A: 请确保客户端每 5 秒发送一次心跳消息（messageType = 2），否则服务器会在 8 秒后自动断开连接。

### Q: 如何处理大文件传输？

A: 使用 `sendDataWithFileURL:` 方法进行流式传输，框架会自动分块发送，避免内存溢出。

### Q: 支持多个客户端同时连接吗？

A: 当前实现使用单例模式，同一时间只支持一个 WebSocket 连接。如需支持多连接，需要修改 WebSocketManager 的实现。

### Q: 如何在生产环境中使用？

A:
1. 关闭调试日志（自动根据 DEBUG 宏控制）
2. 根据需要调整心跳超时时间
3. 添加连接认证机制
4. 实现断线重连逻辑

## 性能优化建议

1. **消息大小**: 单次发送的消息建议不超过 1MB，大数据使用流式传输
2. **心跳间隔**: 可根据网络环境调整心跳间隔，建议 5-10 秒
3. **端口选择**: 避免使用系统保留端口，建议使用 10000-65535 范围
4. **文件清理**: 定期清理临时目录中的流传输文件

## 安全建议

1. **端口访问**: WebSocket 服务器监听本地端口，仅限应用内访问
2. **数据验证**: 对接收到的数据进行验证，防止注入攻击
3. **认证机制**: 在生产环境中添加连接认证
4. **HTTPS**: 考虑使用 SSL/TLS 加密通信

## 版本历史

### 1.0.0
- 初始版本发布
- 支持基本的 WebSocket 通信
- 支持文本和二进制数据传输
- 支持流式文件传输
- 集成 HTTP 文件服务器

## 路线图

未来计划添加的功能：
- [ ] 支持多客户端连接
- [ ] 添加 SSL/TLS 支持
- [ ] 实现连接认证机制
- [ ] 添加更多的消息编码格式支持
- [ ] 提供 Swift 接口
- [ ] 性能监控和统计

## 贡献

欢迎提交 Issue 和 Pull Request！

在提交 PR 之前，请确保：
1. 代码符合项目编码规范
2. 添加必要的注释
3. 通过所有测试用例
4. 更新相关文档

## 许可证

LWWebSocket 基于 MIT 许可证开源。详见 [LICENSE](LICENSE) 文件。

## 作者

**luowei**
Email: luowei@wodedata.com

## 致谢

感谢以下开源项目：
- [CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer)
- [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket)
- [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)

## 相关链接

- [GitHub 仓库](https://github.com/luowei/LWWebSocket)
- [CocoaPods 主页](https://cocoapods.org/pods/LWWebSocket)
- [WebSocket 协议规范](https://tools.ietf.org/html/rfc6455)

---

如有问题或建议，欢迎通过 Issue 或邮件联系。
