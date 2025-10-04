# LWWebSocket Swift/SwiftUI Implementation

This is a Swift/SwiftUI version of the LWWebSocket library, providing in-app WebSocket server functionality with modern Swift patterns.

## Features

- Pure Swift implementation maintaining the same API as the Objective-C version
- SwiftUI integration with Observable pattern
- Type-safe message handling
- Heartbeat mechanism for connection monitoring
- File streaming support
- Modern async/await ready architecture

## Architecture

### Core Components

1. **LWSocketMessageType.swift** - Message type enumeration
2. **MyWebSocket.swift** - WebSocket connection with heartbeat
3. **MyHTTPConnection.swift** - HTTP connection handler
4. **WebSocketManager.swift** - Main singleton manager (compatible with ObjC version)
5. **WebSocketObservable.swift** - SwiftUI reactive wrapper
6. **WebSocketExampleView.swift** - Example SwiftUI implementation

## Usage

### Basic Usage (Swift)

```swift
import LWWebSocket

// Start server
WebSocketManager.shared.startServer(port: 8080, webPath: "websocket")

// Handle received messages
WebSocketManager.shared.handleReceiveMessage = { messageType, message in
    print("Received message type \(messageType): \(message)")
}

// Handle received data
WebSocketManager.shared.handleReceiveData = { messageType, data in
    print("Received data type \(messageType)")
}

// Send a message
WebSocketManager.shared.sendMessage("Hello from Swift!")

// Send binary data
let data = "Test data".data(using: .utf8)!
WebSocketManager.shared.sendData(data)

// Send file
let fileURL = URL(fileURLWithPath: "/path/to/file")
WebSocketManager.shared.sendData(withFileURL: fileURL)

// Stop server
WebSocketManager.shared.stopServer()
```

### SwiftUI Usage

```swift
import SwiftUI
import LWWebSocket

struct ContentView: View {
    @StateObject private var webSocket = WebSocketObservable()
    @State private var message = ""

    var body: some View {
        VStack {
            Text("Server: \(webSocket.isServerRunning ? "Running" : "Stopped")")

            TextField("Message", text: $message)

            Button("Send") {
                webSocket.sendMessage(message)
            }

            if let lastMessage = webSocket.lastReceivedMessage {
                Text("Last: \(lastMessage.message)")
            }
        }
        .onAppear {
            webSocket.startServer(port: 8080, webPath: "websocket")

            webSocket.onReceiveMessage { messageType, message in
                print("Received: \(message)")
            }
        }
    }
}
```

### Using the Example View

```swift
import SwiftUI
import LWWebSocket

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            WebSocketExampleView()
        }
    }
}
```

## Message Types

```swift
public enum LWSocketMessageType: UInt32 {
    case raw = 0
    case hello = 1
    case heartBeat = 2
    case streamStart = 3
    case streaming = 4
    case streamEnd = 5
    case string = 6
    case data = 7
}
```

## API Compatibility

The Swift version maintains the same public API as the Objective-C version:

| Objective-C | Swift |
|------------|-------|
| `[WebSocketManager sharedManager]` | `WebSocketManager.shared` |
| `startServerWithPort:webPath:` | `startServer(port:webPath:)` |
| `stopServer` | `stopServer()` |
| `sendMessage:` | `sendMessage(_:)` |
| `sendData:` | `sendData(_:)` |
| `sendDataWithFileURL:` | `sendData(withFileURL:)` |
| `handleReceiveMessage` | `handleReceiveMessage` |
| `handleReceiveData` | `handleReceiveData` |

## SwiftUI Observable Features

The `WebSocketObservable` class provides:

- `@Published` properties for reactive updates
- Connection status monitoring
- Automatic callback management
- View lifecycle integration

## Integration with Existing Project

To use the Swift version alongside the Objective-C version:

1. Ensure the bridging header is properly configured
2. Import the necessary CocoaHTTPServer headers
3. Both versions can coexist in the same project

## Requirements

- iOS 13.0+ (for SwiftUI features)
- iOS 8.0+ (for core functionality)
- Swift 5.0+
- Xcode 11.0+

## Dependencies

Same as Objective-C version:
- CocoaHTTPServer
- CocoaAsyncSocket
- CocoaLumberjack

## Notes

- The Swift version uses modern Swift patterns while maintaining backward compatibility
- WebSocketObservable is only available on iOS 13.0+ due to SwiftUI requirements
- Core WebSocketManager works on iOS 8.0+ matching the original library
- Heartbeat timeout is set to 8 seconds by default
