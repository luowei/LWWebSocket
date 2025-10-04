# LWWebSocket Swift Implementation

A modern Swift/SwiftUI version of the LWWebSocket library for iOS.

## Overview

This directory contains a complete Swift rewrite of the Objective-C LWWebSocket library, providing the same in-app WebSocket server functionality with modern Swift patterns and SwiftUI support.

## Files

### Core Implementation
- **LWSocketMessageType.swift** (21 lines) - Type-safe enum for message types
- **WebSocketManager.swift** (338 lines) - Main singleton manager matching ObjC API
- **MyWebSocket.swift** (71 lines) - WebSocket subclass with heartbeat functionality
- **MyHTTPConnection.swift** (35 lines) - HTTP connection handler for WebSocket upgrades

### SwiftUI Integration
- **WebSocketObservable.swift** (150 lines) - Observable wrapper for reactive SwiftUI integration
- **WebSocketExampleView.swift** (207 lines) - Complete SwiftUI example demonstrating usage

### Interoperability
- **LWWebSocket-Bridging-Header.h** - Objective-C bridging header for CocoaHTTPServer

### Documentation
- **SWIFT_USAGE.md** - Basic usage examples and API documentation
- **MIGRATION_GUIDE.md** - Complete migration guide from Objective-C to Swift
- **README.md** - This file

## Quick Start

### Basic Swift Usage

```swift
import LWWebSocket

// Start server
WebSocketManager.shared.startServer(port: 8080, webPath: "websocket")

// Handle messages
WebSocketManager.shared.handleReceiveMessage = { messageType, message in
    print("Received: \(message)")
}

// Send message
WebSocketManager.shared.sendMessage("Hello!")
```

### SwiftUI Usage

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var webSocket = WebSocketObservable()
    
    var body: some View {
        VStack {
            Text("Status: \(webSocket.isServerRunning ? "Running" : "Stopped")")
        }
        .onAppear {
            webSocket.startServer(port: 8080, webPath: "websocket")
        }
    }
}
```

## Features

- ✅ Same API as Objective-C version
- ✅ Type-safe message type enum
- ✅ SwiftUI reactive integration
- ✅ Heartbeat mechanism
- ✅ File streaming support
- ✅ Modern Swift patterns
- ✅ Full backward compatibility
- ✅ Comprehensive documentation

## Architecture

```
Swift/
├── Core Components
│   ├── LWSocketMessageType.swift      # Message types enum
│   ├── WebSocketManager.swift         # Main singleton (ObjC compatible)
│   ├── MyWebSocket.swift              # WebSocket with heartbeat
│   └── MyHTTPConnection.swift         # HTTP connection handler
│
├── SwiftUI Layer
│   ├── WebSocketObservable.swift     # Reactive wrapper
│   └── WebSocketExampleView.swift    # Example implementation
│
├── Interop
│   └── LWWebSocket-Bridging-Header.h # ObjC bridge
│
└── Documentation
    ├── SWIFT_USAGE.md                # Usage guide
    ├── MIGRATION_GUIDE.md            # Migration from ObjC
    └── README.md                     # This file
```

## Requirements

- iOS 8.0+ (Core functionality)
- iOS 13.0+ (SwiftUI features)
- Swift 5.0+
- Xcode 11.0+

## Dependencies

Same as the Objective-C version:
- CocoaHTTPServer (included in Library/)
- CocoaAsyncSocket (included in Library/)
- CocoaLumberjack (included in Library/)

## API Compatibility

The Swift implementation maintains 100% API compatibility with the Objective-C version:

| Feature | Objective-C | Swift |
|---------|-------------|-------|
| Singleton | `[WebSocketManager sharedManager]` | `WebSocketManager.shared` |
| Start server | `startServerWithPort:webPath:` | `startServer(port:webPath:)` |
| Stop server | `stopServer` | `stopServer()` |
| Send message | `sendMessage:` | `sendMessage(_:)` |
| Send data | `sendData:` | `sendData(_:)` |
| Send file | `sendDataWithFileURL:` | `sendData(withFileURL:)` |

## Integration

### With Existing Objective-C Project

Both implementations can coexist:

```objc
// Objective-C code
#import "WebSocketManager.h"
[[WebSocketManager sharedManager] startServerWithPort:8080 webPath:@"ws"];
```

```swift
// Swift code
import LWWebSocket
WebSocketManager.shared.startServer(port: 8080, webPath: "ws")
```

### SwiftUI-Only Project

Use the Observable wrapper:

```swift
@StateObject private var webSocket = WebSocketObservable()
```

## Examples

See `WebSocketExampleView.swift` for a complete working example with:
- Server status display
- Message sending/receiving
- Data transmission
- Connection monitoring
- SwiftUI best practices

## Testing

The Swift implementation uses the same WebSocket protocol as the Objective-C version, so existing HTML/JavaScript test clients work without modification.

## Migration

For migrating from Objective-C to Swift, see `MIGRATION_GUIDE.md` for:
- Side-by-side code comparisons
- Step-by-step migration path
- API mapping table
- Common patterns and idioms

## Contributing

When contributing to the Swift implementation:
1. Maintain API compatibility with Objective-C version
2. Follow Swift naming conventions
3. Add comprehensive documentation
4. Include usage examples
5. Test with both Swift and SwiftUI

## License

Same as the main LWWebSocket library (see LICENSE in project root).

## Support

- For Swift-specific questions, see SWIFT_USAGE.md
- For migration help, see MIGRATION_GUIDE.md
- For examples, see WebSocketExampleView.swift
- For general issues, refer to the main project documentation

## Version

Swift Version: 1.0.0 (matches LWWebSocket 1.0.0)
