# LWWebSocket Swift Version

## 概述

LWWebSocket_swift 是 LWWebSocket 的 Swift 版本实现，提供了现代化的 Swift API 用于在 APP 内创建轻量级的 WebSocket 数据传输服务器。

## 安装

### CocoaPods

在您的 `Podfile` 中添加：

```ruby
pod 'LWWebSocket_swift'
```

然后运行：

```bash
pod install
```

## 使用方法

### Swift

```swift
import LWWebSocket_swift

// 创建 WebSocket 管理器
let webSocketManager = WebSocketManager.shared

// 启动 WebSocket 服务器
webSocketManager.start(onPort: 8080)

// 发送消息
webSocketManager.sendMessage("Hello, WebSocket!", type: .text)

// 接收消息
webSocketManager.onMessageReceived = { message in
    print("Received: \(message)")
}

// 停止服务器
webSocketManager.stop()
```

### SwiftUI (使用 Observable)

```swift
import SwiftUI
import LWWebSocket_swift

struct ContentView: View {
    @ObservedObject var webSocket = WebSocketObservable.shared

    var body: some View {
        VStack {
            Text("Status: \(webSocket.isConnected ? "Connected" : "Disconnected")")

            Button("Start Server") {
                webSocket.startServer(onPort: 8080)
            }

            Button("Send Message") {
                webSocket.sendMessage("Hello from SwiftUI!")
            }

            List(webSocket.messages, id: \.self) { message in
                Text(message)
            }
        }
    }
}
```

## 主要特性

- **轻量级服务器**: 在 APP 内运行的 WebSocket 服务器
- **双向通信**: 支持客户端和服务器之间的实时双向通信
- **消息类型**: 支持文本和二进制消息
- **SwiftUI 支持**: 提供 ObservableObject 用于响应式更新
- **简单易用**: 简洁的 API 设计，易于集成

## 组件说明

- **WebSocketManager**: 核心管理类，处理 WebSocket 连接和消息
- **WebSocketObservable**: SwiftUI ObservableObject，用于响应式编程
- **LWSocketMessageType**: 消息类型枚举
- **MyWebSocket**: 自定义 WebSocket 实现
- **MyHTTPConnection**: HTTP 连接处理

## 系统要求

- iOS 11.0+
- Swift 5.0+
- Xcode 12.0+

## 与 Objective-C 版本的关系

- **LWWebSocket**: Objective-C 版本，适用于传统的 Objective-C 项目
- **LWWebSocket_swift**: Swift 版本，提供现代化的 Swift API 和 SwiftUI 支持

您可以根据项目需要选择合适的版本。两个版本功能相同，但 Swift 版本提供了更好的类型安全性和 SwiftUI 集成。

## License

LWWebSocket_swift is available under the MIT license. See the LICENSE file for more info.
