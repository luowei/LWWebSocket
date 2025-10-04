# Migration Guide: Objective-C to Swift

This guide helps you migrate from the Objective-C implementation to the Swift implementation of LWWebSocket.

## File Mapping

| Objective-C | Swift | Notes |
|------------|-------|-------|
| `WebSocketManager.h/.m` | `WebSocketManager.swift` | Main singleton manager |
| - | `LWSocketMessageType.swift` | Type-safe enum (was typedef in .h) |
| - | `MyWebSocket.swift` | Internal class (was in .m) |
| - | `MyHTTPConnection.swift` | Internal class (was in .m) |
| - | `WebSocketObservable.swift` | New SwiftUI wrapper |
| - | `WebSocketExampleView.swift` | SwiftUI demo |
| - | `LWWebSocket-Bridging-Header.h` | ObjC interop |

## API Migration Examples

### Starting the Server

**Objective-C:**
```objc
[[WebSocketManager sharedManager] startServerWithPort:8080 webPath:@"websocket"];
```

**Swift:**
```swift
WebSocketManager.shared.startServer(port: 8080, webPath: "websocket")
```

### Stopping the Server

**Objective-C:**
```objc
[[WebSocketManager sharedManager] stopServer];
```

**Swift:**
```swift
WebSocketManager.shared.stopServer()
```

### Handling Messages

**Objective-C:**
```objc
[WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType, NSString *message) {
    NSLog(@"Received: %@", message);
};
```

**Swift:**
```swift
WebSocketManager.shared.handleReceiveMessage = { messageType, message in
    print("Received: \(message)")
}
```

### Handling Data

**Objective-C:**
```objc
[WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType, NSData *data) {
    NSLog(@"Received data: %lu bytes", (unsigned long)data.length);
};
```

**Swift:**
```swift
WebSocketManager.shared.handleReceiveData = { messageType, data in
    if let data = data {
        print("Received data: \(data.count) bytes")
    }
}
```

### Sending Messages

**Objective-C:**
```objc
BOOL success = [[WebSocketManager sharedManager] sendMessage:@"Hello"];
```

**Swift:**
```swift
let success = WebSocketManager.shared.sendMessage("Hello")
```

### Sending Data

**Objective-C:**
```objc
NSData *data = [@"Test" dataUsingEncoding:NSUTF8StringEncoding];
BOOL success = [[WebSocketManager sharedManager] sendData:data];
```

**Swift:**
```swift
let data = "Test".data(using: .utf8)!
let success = WebSocketManager.shared.sendData(data)
```

### Sending Files

**Objective-C:**
```objc
NSURL *fileURL = [NSURL fileURLWithPath:@"/path/to/file"];
BOOL success = [[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];
```

**Swift:**
```swift
let fileURL = URL(fileURLWithPath: "/path/to/file")
let success = WebSocketManager.shared.sendData(withFileURL: fileURL)
```

## Message Type Enum

**Objective-C:**
```objc
typedef NS_OPTIONS(uint32_t, LWSocketMessageType) {
    SocketMessageType_Raw = 0,
    SocketMessageType_Hello = 1,
    SocketMessageType_HeartBeat = 2,
    // ...
};
```

**Swift:**
```swift
public enum LWSocketMessageType: UInt32 {
    case raw = 0
    case hello = 1
    case heartBeat = 2
    // ...
}
```

**Usage:**
```swift
// Check message type
if messageType == LWSocketMessageType.heartBeat.rawValue {
    // Handle heartbeat
}

// Create message type
let type = LWSocketMessageType.hello
let rawValue = type.rawValue // UInt32
```

## SwiftUI Integration (New Feature)

The Swift version adds SwiftUI support through `WebSocketObservable`:

```swift
import SwiftUI

struct MyView: View {
    @StateObject private var webSocket = WebSocketObservable()

    var body: some View {
        VStack {
            Text("Server: \(webSocket.isServerRunning ? "Running" : "Stopped")")

            if let message = webSocket.lastReceivedMessage {
                Text("Last: \(message.message)")
            }
        }
        .onAppear {
            webSocket.startServer(port: 8080, webPath: "websocket")
        }
    }
}
```

## Key Differences

### 1. Property Access
- **Objective-C:** `[WebSocketManager sharedManager]`
- **Swift:** `WebSocketManager.shared`

### 2. Method Naming
- **Objective-C:** `startServerWithPort:webPath:`
- **Swift:** `startServer(port:webPath:)`

### 3. Type Safety
- **Objective-C:** `uint32_t messageType`
- **Swift:** `UInt32` or `LWSocketMessageType` enum

### 4. Closures
- **Objective-C:** Blocks with `^`
- **Swift:** Closures with `{ }`

### 5. Optionals
- **Objective-C:** `nil` checks
- **Swift:** Optional binding with `if let`, `guard let`

### 6. Error Handling
- **Objective-C:** `NSError **error`
- **Swift:** `do-try-catch` or `try?`

## Benefits of Swift Version

1. **Type Safety**: Enums and strong typing prevent runtime errors
2. **Modern Syntax**: Cleaner, more readable code
3. **SwiftUI Support**: Native reactive programming
4. **Better Optionals**: Swift optionals prevent nil-related crashes
5. **Value Types**: Swift structs and enums are safer
6. **Memory Management**: Automatic reference counting is simpler

## Backward Compatibility

Both Objective-C and Swift versions can coexist in the same project. The Swift version wraps the same underlying CocoaHTTPServer framework, ensuring identical behavior.

To use both:
1. Keep the bridging header configured
2. Import the module where needed
3. Both versions use the same singleton pattern

## Recommended Migration Path

1. **Phase 1**: Use Swift version in new code only
2. **Phase 2**: Migrate view controllers to SwiftUI with `WebSocketObservable`
3. **Phase 3**: Replace Objective-C calls with Swift equivalents
4. **Phase 4**: Remove Objective-C implementation if fully migrated

## Testing

Both implementations share the same WebSocket protocol, so you can test with the same HTML clients:

```javascript
// Client-side JavaScript (works with both implementations)
var ws = new WebSocket('ws://localhost:8080/service');

ws.onopen = function() {
    console.log('Connected');
    ws.send(JSON.stringify({
        messageType: 6,
        messageBody: "Hello from client"
    }));
};

ws.onmessage = function(event) {
    console.log('Received:', event.data);
};
```

## Support

For issues or questions:
- Check `SWIFT_USAGE.md` for basic usage
- Review `WebSocketExampleView.swift` for a complete example
- Compare with original Objective-C implementation in `Classes/`
