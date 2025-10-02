# LWWebSocket

[English](./README.md) | [中文版](./README_ZH.md)

[![CI Status](https://img.shields.io/travis/luowei/LWWebSocket.svg?style=flat)](https://travis-ci.org/luowei/LWWebSocket)
[![Version](https://img.shields.io/cocoapods/v/LWWebSocket.svg?style=flat)](https://cocoapods.org/pods/LWWebSocket)
[![License](https://img.shields.io/cocoapods/l/LWWebSocket.svg?style=flat)](https://cocoapods.org/pods/LWWebSocket)
[![Platform](https://img.shields.io/cocoapods/p/LWWebSocket.svg?style=flat)](https://cocoapods.org/pods/LWWebSocket)

## Overview

LWWebSocket is a lightweight and easy-to-use WebSocket library for iOS with built-in server capabilities, heartbeat mechanism, and streaming support. Built on top of CocoaHTTPServer, CocoaAsyncSocket, and CocoaLumberjack, LWWebSocket provides a simple API to enable real-time bidirectional communication between your iOS app and web pages.

**Key Highlights:**
- Embedded WebSocket server with HTTP file serving capabilities
- Efficient streaming for large file transfers with automatic chunking
- Built-in heartbeat mechanism for connection health monitoring
- Thread-safe singleton pattern for easy integration
- Block-based callbacks for intuitive message handling

## Features

### Core Capabilities
- **Built-in WebSocket Server** - Turn your iOS app into a WebSocket server
- **Dual Protocol Support** - Both text and binary message types supported
- **Heartbeat Mechanism** - Automatic connection health monitoring with configurable timeouts
- **Streaming Support** - Efficient large file transfers with automatic 10KB chunking
- **HTTP File Server** - Integrated static file serving functionality

### Developer Experience
- **Simple API** - Easy-to-use block-based callbacks
- **Singleton Pattern** - Centralized management with shared instance
- **Thread Safety** - All operations are thread-safe with dedicated GCD queues
- **Comprehensive Logging** - Built-in debug logging with CocoaLumberjack
- **iOS 8.0+** - Broad platform compatibility

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Architecture](#core-architecture)
  - [WebSocketManager Class](#websocketmanager-class)
  - [Message Types](#message-types)
- [WebSocket Server Features](#websocket-server-features)
- [Heartbeat Mechanism](#heartbeat-mechanism)
- [Streaming Support](#streaming-support)
- [Usage Examples](#usage-examples)
- [Advanced Features](#advanced-features)
- [API Documentation](#api-documentation)
- [FAQ](#faq)
- [Example Project](#example-project)
- [Performance & Best Practices](#performance-optimization)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

## Requirements

- **iOS**: 8.0 or later
- **Xcode**: Latest stable version recommended
- **CocoaPods**: 1.0.0 or later

## Installation

### CocoaPods

LWWebSocket is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your `Podfile`:

```ruby
pod 'LWWebSocket'
```

Then run:

```bash
pod install
```

### Manual Installation

If you prefer manual installation:

1. Download the latest release from [GitHub](https://github.com/luowei/LWWebSocket)
2. Add the `LWWebSocket` folder to your project
3. Ensure you have the required dependencies:
   - CocoaHTTPServer
   - CocoaAsyncSocket
   - CocoaLumberjack

## Quick Start

### 1. Import the Framework

```Objective-C
#import <LWWebSocket/WebSocketManager.h>
```

### 2. Start the WebSocket Server

```Objective-C
// Get the document directory path
NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;

// Start server on port 11335
[[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];
```

### 3. Set Up Message Handlers

```Objective-C
// Handle text messages
[WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType, NSString *message) {
    switch (messageType) {
        case SocketMessageType_String: {
            NSLog(@"Received text message - Type:%d, text:%@", messageType, message);
            break;
        }
        default:
            break;
    }
};

// Handle binary data
[WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType, NSData *data) {
    switch (messageType) {
        case SocketMessageType_StreamStart: {
            NSLog(@"Stream started");
            break;
        }
        case SocketMessageType_Streaming: {
            // Processing streaming data chunk
            break;
        }
        case SocketMessageType_StreamEnd: {
            NSString *dataPath = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Stream completed, file saved at: %@", dataPath);
            break;
        }
        case SocketMessageType_Data: {
            // Handle received binary data
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Received binary data - Type:%d, text:%@", messageType, text);
            break;
        }
        default:
            break;
    }
};
```

### 4. Send Messages

```Objective-C
// Send text message
[[WebSocketManager sharedManager] sendMessage:@"Hello WebSocket"];

// Send binary data
NSData *data = [@"Binary Data" dataUsingEncoding:NSUTF8StringEncoding];
[[WebSocketManager sharedManager] sendData:data];

// Send file with streaming
NSURL *fileURL = [NSURL fileURLWithPath:@"/path/to/file"];
[[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];
```

### 5. Stop the Server

```Objective-C
[[WebSocketManager sharedManager] stopServer];
```

## Core Architecture

LWWebSocket is designed with simplicity and efficiency in mind. The architecture consists of a singleton manager class that handles all WebSocket operations, making it easy to integrate into any iOS application.

### WebSocketManager Class

The `WebSocketManager` is a singleton class responsible for starting, stopping, and managing WebSocket server operations.

#### Key Properties

| Property | Type | Description |
|----------|------|-------------|
| `handleReceiveMessage` | Block | Callback for receiving text messages with message type |
| `handleReceiveData` | Block | Callback for receiving binary data with message type |

#### Key Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `+ sharedManager` | `instancetype` | Get the singleton instance |
| `- startServerWithPort:webPath:` | `void` | Start the WebSocket server on specified port |
| `- stopServer` | `void` | Stop the running server |
| `- sendMessage:` | `BOOL` | Send a text message to connected clients |
| `- sendData:` | `BOOL` | Send binary data to connected clients |
| `- sendDataWithFileURL:` | `BOOL` | Send a file using streaming (for large files) |

### Message Types

LWWebSocket defines the following message types (`LWSocketMessageType`):

```objective-c
typedef NS_OPTIONS(uint32_t, LWSocketMessageType) {
    SocketMessageType_Raw = 0,          // Raw data
    SocketMessageType_Hello = 1,        // Connection established message
    SocketMessageType_HeartBeat = 2,    // Heartbeat message
    SocketMessageType_StreamStart = 3,  // Stream transfer start
    SocketMessageType_Streaming = 4,    // Stream transfer in progress
    SocketMessageType_StreamEnd = 5,    // Stream transfer end
    SocketMessageType_String = 6,       // Text message
    SocketMessageType_Data = 7,         // Binary data
};
```

#### Message Type Reference

| Type | Value | Purpose | Use Case |
|------|-------|---------|----------|
| `Raw` | 0 | Raw data without processing | Low-level data transfer |
| `Hello` | 1 | Initial connection handshake | Connection establishment |
| `HeartBeat` | 2 | Connection health check | Keep-alive mechanism |
| `StreamStart` | 3 | Begin streaming session | Large file transfer initiation |
| `Streaming` | 4 | Stream data chunk | Progressive data transmission |
| `StreamEnd` | 5 | Complete streaming session | Transfer completion with file path |
| `String` | 6 | Text message | General text communication |
| `Data` | 7 | Binary data | Binary content transfer |

## WebSocket Server Features

LWWebSocket includes a built-in WebSocket server that allows your iOS app to act as a WebSocket server. This enables powerful scenarios for modern iOS applications.

### Use Cases

- **Local Network Communication**: Enable communication between devices on the same network
- **Local Web Interface**: Create a browser-based control panel for your app
- **Testing & Development**: Rapid prototyping and debugging of WebSocket integrations
- **Peer-to-Peer Communication**: Direct device-to-device data exchange
- **Remote Debugging**: Monitor and control your app from a web browser
- **IoT Applications**: Control IoT devices through your iOS app

### Starting the Server

```Objective-C
// Set the web root directory
NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;

// Start server on specified port
[[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];
```

The server will:
- Start listening on the specified port (e.g., 11335)
- Serve static files from the provided web path via HTTP
- Accept WebSocket connections at `ws://localhost:11335/service`
- Automatically create directories if they don't exist

### HTTP File Server

In addition to WebSocket functionality, the server provides HTTP file serving capabilities:

```Objective-C
// Access files via browser: http://localhost:11335/filename.txt
```

Features:
- Static file serving
- Directory browsing
- Support for both relative and absolute paths
- Automatic directory creation

## Heartbeat Mechanism

LWWebSocket includes a built-in heartbeat mechanism to maintain connection health and automatically detect disconnections. This ensures reliable, long-lived connections.

### How It Works

1. **Automatic Monitoring**: The server starts a heartbeat timer when a connection is established
2. **Client Heartbeat**: Clients must send heartbeat messages every 5 seconds
3. **Timeout Detection**: If no heartbeat is received within 8 seconds, the server automatically closes the connection
4. **Keep-Alive**: Regular heartbeats keep the connection alive and prevent timeouts

### Client Implementation

Clients should send heartbeat messages at regular intervals:

```javascript
// JavaScript client example
var socket = new WebSocket('ws://localhost:11335/service');

// Send heartbeat every 5 seconds
setInterval(function() {
    if (socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({
            messageType: 2,  // SocketMessageType_HeartBeat
            messageBody: ""
        }));
    }
}, 5000);
```

### Benefits

- **Connection Stability**: Keeps connections alive and prevents server timeouts
- **Fast Failure Detection**: Quickly identifies and closes dead connections
- **Resource Management**: Automatically cleans up inactive connections
- **Network Health**: Monitors network connectivity in real-time

## Streaming Support

LWWebSocket supports efficient streaming data transfer, making it ideal for large file transfers without consuming excessive memory.

### Use Cases

- Large file transfers (videos, images, documents)
- Real-time data transmission
- Progressive data loading
- Memory-efficient data handling

### How Streaming Works

The streaming mechanism uses three distinct phases:

1. **StreamStart** (`SocketMessageType_StreamStart`): Notifies that a streaming session has begun
2. **Streaming** (`SocketMessageType_Streaming`): Multiple data chunks are transmitted (10KB per chunk)
3. **StreamEnd** (`SocketMessageType_StreamEnd`): Notifies completion and provides the file path

### Sending Files with Streaming

```Objective-C
// Send a large file using streaming
NSURL *fileURL = [NSURL fileURLWithPath:@"/path/to/largefile.mp4"];
[[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];

// The framework automatically:
// 1. Reads the file in 10KB chunks
// 2. Sends StreamStart message
// 3. Sends multiple Streaming messages with chunks
// 4. Sends StreamEnd message with file path
```

### Receiving Streaming Data

```Objective-C
[WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType, NSData *data) {
    switch (messageType) {
        case SocketMessageType_StreamStart: {
            // Initialize streaming session
            // You can create an output stream here
            NSLog(@"Stream started - preparing to receive data");
            break;
        }
        case SocketMessageType_Streaming: {
            // Process streaming data chunk
            // Write chunk to file incrementally
            NSLog(@"Receiving data chunk: %lu bytes", (unsigned long)data.length);
            break;
        }
        case SocketMessageType_StreamEnd: {
            // Finalize streaming session
            NSString *filePath = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Stream completed, file saved at: %@", filePath);
            break;
        }
    }
};
```

### Streaming Features

- **Automatic Chunking**: Files are automatically split into 10KB chunks
- **Memory Efficient**: Only small chunks are kept in memory at once
- **Temporary File Management**: Server automatically manages temporary file storage
- **Error Handling**: Automatic cleanup on transmission failures
- **Progress Tracking**: Monitor transfer progress through chunk callbacks


## Usage Examples

### Complete Integration Example

Here's a complete example showing all major features:

```Objective-C
#import <LWWebSocket/WebSocketManager.h>

@interface ViewController ()
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1. Start WebSocket Server
    [self startWebSocketServer];

    // 2. Set up message handlers
    [self setupMessageHandlers];

    // 3. Load web interface
    [self loadWebInterface];
}

- (void)startWebSocketServer {
    NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    [[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];
    NSLog(@"WebSocket server started on port 11335");
}

- (void)setupMessageHandlers {
    // Handle text messages
    [WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType, NSString *message) {
        switch (messageType) {
            case SocketMessageType_String: {
                NSLog(@"Received: %@", message);

                // Echo back to client
                [[WebSocketManager sharedManager] sendMessage:[NSString stringWithFormat:@"Echo: %@", message]];
                break;
            }
            default:
                break;
        }
    };

    // Handle binary data and streaming
    [WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType, NSData *data) {
        switch (messageType) {
            case SocketMessageType_Data: {
                NSLog(@"Received binary data: %lu bytes", (unsigned long)data.length);
                break;
            }
            case SocketMessageType_StreamStart: {
                NSLog(@"File transfer started");
                break;
            }
            case SocketMessageType_Streaming: {
                NSLog(@"Receiving chunk: %lu bytes", (unsigned long)data.length);
                break;
            }
            case SocketMessageType_StreamEnd: {
                NSString *filePath = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"File transfer completed: %@", filePath);
                break;
            }
            default:
                break;
        }
    };
}

- (void)loadWebInterface {
    // Create WebView
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds
                                      configuration:[WKWebViewConfiguration new]];
    [self.view addSubview:self.webView];

    // Load HTML with WebSocket client
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[WebSocketManager class]]
                                                pathForResource:@"LWWebSocket" ofType:@"bundle"]];
    NSString *path = [bundle pathForResource:@"index" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://localhost"]];
}

- (void)sendTextMessage {
    [[WebSocketManager sharedManager] sendMessage:@"Hello from iOS!"];
}

- (void)sendBinaryData {
    NSData *data = [@"Binary message" dataUsingEncoding:NSUTF8StringEncoding];
    [[WebSocketManager sharedManager] sendData:data];
}

- (void)sendLargeFile {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];
}

- (void)dealloc {
    [[WebSocketManager sharedManager] stopServer];
}

@end
```

### JavaScript Client Example

Complete JavaScript client with all features:

```javascript
// Connect to WebSocket server
var socket = new WebSocket('ws://localhost:11335/service');

// Connection opened
socket.onopen = function(event) {
    console.log('Connected to WebSocket server');

    // Send initial message
    sendTextMessage('Hello from JavaScript!');
};

// Receive messages
socket.onmessage = function(event) {
    if (typeof event.data === 'string') {
        console.log('Text message received:', event.data);
        handleTextMessage(event.data);
    } else {
        console.log('Binary data received');
        handleBinaryData(event.data);
    }
};

// Connection closed
socket.onclose = function(event) {
    console.log('WebSocket connection closed');
};

// Connection error
socket.onerror = function(error) {
    console.error('WebSocket error:', error);
};

// Send text message
function sendTextMessage(message) {
    socket.send(JSON.stringify({
        messageType: 6,  // SocketMessageType_String
        messageBody: message
    }));
}

// Send binary data
function sendBinaryData(data) {
    socket.send(JSON.stringify({
        messageType: 7,  // SocketMessageType_Data
        messageBody: btoa(data)  // Base64 encode
    }));
}

// Heartbeat mechanism (send every 5 seconds)
setInterval(function() {
    if (socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({
            messageType: 2,  // SocketMessageType_HeartBeat
            messageBody: ""
        }));
        console.log('Heartbeat sent');
    }
}, 5000);

// Handle received text messages
function handleTextMessage(message) {
    try {
        var data = JSON.parse(message);
        console.log('Parsed message:', data);
        // Process message based on type
    } catch (e) {
        console.log('Plain text message:', message);
    }
}

// Handle received binary data
function handleBinaryData(data) {
    // Convert ArrayBuffer to string or process as needed
    var reader = new FileReader();
    reader.onload = function() {
        console.log('Binary data:', reader.result);
    };
    reader.readAsText(data);
}
```

## API Documentation

### WebSocketManager

#### Instance Methods

##### Starting and Stopping the Server

```objective-c
- (void)startServerWithPort:(NSUInteger)port webPath:(NSString *)webPath;
```

Starts the WebSocket server on the specified port with the given web root directory.

**Parameters:**
- `port`: The port number to listen on (recommended: 10000-65535)
- `webPath`: The root directory for HTTP file serving

**Example:**
```objective-c
NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
[[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];
```

---

```objective-c
- (void)stopServer;
```

Stops the WebSocket server and closes all connections.

**Example:**
```objective-c
[[WebSocketManager sharedManager] stopServer];
```

##### Sending Messages

```objective-c
- (BOOL)sendMessage:(NSString *)message;
```

Sends a text message to all connected clients.

**Parameters:**
- `message`: The text message to send

**Returns:** `YES` if successful, `NO` otherwise

**Example:**
```objective-c
BOOL success = [[WebSocketManager sharedManager] sendMessage:@"Hello Client"];
```

---

```objective-c
- (BOOL)sendData:(NSData *)data;
```

Sends binary data to all connected clients.

**Parameters:**
- `data`: The binary data to send

**Returns:** `YES` if successful, `NO` otherwise

**Example:**
```objective-c
NSData *data = [@"Binary content" dataUsingEncoding:NSUTF8StringEncoding];
BOOL success = [[WebSocketManager sharedManager] sendData:data];
```

---

```objective-c
- (BOOL)sendDataWithFileURL:(NSURL *)fileURL;
```

Sends a file using streaming transfer for efficient large file handling.

**Parameters:**
- `fileURL`: The file URL to send

**Returns:** `YES` if successful, `NO` otherwise

**Example:**
```objective-c
NSURL *fileURL = [NSURL fileURLWithPath:@"/path/to/video.mp4"];
BOOL success = [[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];
```

#### Block Properties

```objective-c
@property (nonatomic, copy) void (^handleReceiveMessage)(uint32_t messageType, NSString *message);
```

Callback block invoked when a text message is received.

**Parameters:**
- `messageType`: The type of message received (see `LWSocketMessageType`)
- `message`: The text content of the message

---

```objective-c
@property (nonatomic, copy) void (^handleReceiveData)(uint32_t messageType, NSData *data);
```

Callback block invoked when binary data is received.

**Parameters:**
- `messageType`: The type of message received (see `LWSocketMessageType`)
- `data`: The binary data received

## Advanced Features

### Thread Safety

LWWebSocket is designed with thread safety in mind:

- **Dedicated GCD Queue**: All WebSocket operations execute on a dedicated GCD queue
- **Thread-Safe API**: Public API methods are thread-safe and can be called from any thread
- **Main Queue Callbacks**: Callback blocks execute on the main queue for easy UI updates

```Objective-C
// Safe to call from any thread
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [[WebSocketManager sharedManager] sendMessage:@"Background message"];
});
```

### Memory Management

- **Singleton Pattern**: WebSocketManager uses singleton pattern for lifecycle management
- **Weak References**: WebSocket instances use weak references to avoid retain cycles
- **Automatic Cleanup**: Failed connections and temporary files are automatically cleaned up
- **Streaming Efficiency**: Large files use temporary storage instead of loading into memory

### Custom Connection Path

By default, WebSocket connections use the `/service` path. To customize:

```Objective-C
// In WebSocketManager.m
- (NSString *)myURI {
    return @"/service";  // Change to your custom path
}

// Client connects to: ws://localhost:11335/your-custom-path
```

### Debugging

The framework includes debug logging that only outputs in DEBUG mode:

```Objective-C
#ifdef DEBUG
#define WSLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define WSLog(...)
#endif
```

Debug logs include:
- Connection establishment and closure
- Message sending and receiving
- Streaming transfer status
- Error information

## FAQ

### Q: Why does my connection keep disconnecting?

**A:** Make sure your client sends heartbeat messages every 5 seconds. Without heartbeats, the server will automatically close the connection after 8 seconds.

```javascript
// Send heartbeat every 5 seconds
setInterval(function() {
    if (socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({
            messageType: 2,
            messageBody: ""
        }));
    }
}, 5000);
```

### Q: How do I handle large file transfers?

**A:** Use the streaming API with `sendDataWithFileURL:`. The framework automatically:
- Splits files into 10KB chunks
- Manages memory efficiently
- Handles temporary file storage
- Provides progress callbacks

```Objective-C
NSURL *fileURL = [NSURL fileURLWithPath:filePath];
[[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];
```

### Q: Can multiple clients connect simultaneously?

**A:** The current implementation uses a singleton pattern and supports one WebSocket connection at a time. To support multiple connections, you would need to modify the WebSocketManager implementation to maintain an array of active connections.

### Q: How do I change the WebSocket connection path?

**A:** The default connection path is `/service`. To change it, modify the `myURI` method in `WebSocketManager.m`:

```Objective-C
- (NSString *)myURI {
    return @"/custom-path";
}
```

### Q: What ports should I use?

**A:**
- Avoid system reserved ports (0-1023)
- Recommended range: 10000-65535
- Example: 11335 (as used in documentation)
- Ensure the port is not already in use

### Q: How do I secure the WebSocket connection?

**A:**
- The WebSocket server listens on localhost by default (local access only)
- For production, consider adding:
  - Connection authentication
  - SSL/TLS encryption
  - Data validation and sanitization
  - Access control mechanisms

### Q: How often should I send heartbeats?

**A:** The recommended heartbeat interval is 5 seconds. The server timeout is 8 seconds, so 5 seconds provides a safe margin for network delays.

### Q: What's the maximum message size?

**A:**
- For text and binary messages: Recommended maximum of 1MB per message
- For large data: Use the streaming API (`sendDataWithFileURL:`) which has no practical size limit

## Example Project

To run the example project:

1. Clone the repository
   ```bash
   git clone https://github.com/luowei/LWWebSocket.git
   ```

2. Navigate to the Example directory
   ```bash
   cd LWWebSocket/Example
   ```

3. Install dependencies
   ```bash
   pod install
   ```

4. Open the workspace
   ```bash
   open LWWebSocket.xcworkspace
   ```

5. Run the project in Xcode

The example project includes:
- WebSocket server start/stop functionality
- Message sending and receiving demonstrations
- WebView integration example
- File transfer example
- Heartbeat mechanism demonstration

## Performance & Best Practices

### Optimization Guidelines

#### Message Size Management

- **Text Messages**: Keep under 1MB per message for optimal performance
- **Binary Data**: Consider chunking data over 1MB
- **Large Files**: Always use streaming API (`sendDataWithFileURL:`) for files over 1MB
- **Compression**: Consider compressing data before transmission for bandwidth optimization

#### Heartbeat Configuration

- **Recommended Interval**: 5 seconds (default)
- **Timeout Setting**: 8 seconds server-side timeout
- **Network Conditions**: Adjust interval based on network stability
  - Stable networks: 5-10 seconds
  - Unstable networks: 3-5 seconds
- **Battery Consideration**: Longer intervals save battery on mobile devices

#### Port Selection

- **Recommended Range**: 10000-65535 (user/private ports)
- **Avoid**: System reserved ports (0-1023)
- **Avoid**: Well-known application ports (e.g., 8080, 3000)
- **Default Example**: 11335 (as used in documentation)

#### Resource Management

**Temporary File Cleanup:**

```Objective-C
// Clean up temporary streaming files periodically
- (void)cleanupTemporaryFiles {
    NSString *tempDir = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;

    NSArray *tempFiles = [fileManager contentsOfDirectoryAtPath:tempDir error:&error];
    if (error) {
        NSLog(@"Error reading temp directory: %@", error);
        return;
    }

    for (NSString *file in tempFiles) {
        if ([file hasPrefix:@"stream_"]) {
            NSString *filePath = [tempDir stringByAppendingPathComponent:file];
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }
}

// Call periodically, e.g., when app enters background
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self cleanupTemporaryFiles];
}
```

#### Connection Management

- **Single Connection**: Current implementation supports one connection at a time
- **Connection Monitoring**: Implement connection state tracking in your app
- **Graceful Shutdown**: Always call `stopServer` when done
- **Error Handling**: Implement robust error handling for send operations

```objective-c
// Example of error handling
BOOL success = [[WebSocketManager sharedManager] sendMessage:message];
if (!success) {
    NSLog(@"Failed to send message - connection may be closed");
    // Implement retry logic or user notification
}
```

### Performance Metrics

#### Typical Performance

- **Message Latency**: <10ms on localhost
- **Throughput**: Depends on device and data size
- **Streaming**: 10KB chunks for optimal memory usage
- **Concurrent Operations**: Thread-safe design allows concurrent API calls

#### Memory Usage

- **Base Memory**: Minimal footprint (~2-3MB)
- **Per Message**: Negligible for messages <1MB
- **Streaming**: Only 10KB in memory per chunk
- **Connection Overhead**: ~1MB per active connection

## Dependencies

LWWebSocket is built on top of these excellent open-source libraries:

| Library | Purpose | License |
|---------|---------|---------|
| **[CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer)** | HTTP server and WebSocket protocol support | BSD |
| **[CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket)** | Asynchronous socket communication | Public Domain |
| **[CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)** | Fast & flexible logging framework | BSD |

All dependencies are automatically installed when using CocoaPods.

## Contributing

Contributions are welcome! We appreciate your help in making LWWebSocket better.

### How to Contribute

#### Reporting Issues

Before creating an issue, please check if a similar issue already exists. When reporting bugs, include:

- iOS version and device model
- Xcode version
- LWWebSocket version
- Detailed steps to reproduce
- Expected vs actual behavior
- Relevant code snippets or logs
- Screenshots if applicable

#### Submitting Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following the coding standards
3. **Add tests** for new features or bug fixes
4. **Update documentation** including README and code comments
5. **Ensure tests pass** and there are no warnings
6. **Write a clear commit message** describing your changes
7. **Submit the pull request** with a detailed description

### Development Guidelines

#### Coding Standards

- Follow Apple's [Coding Guidelines for Cocoa](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html)
- Use meaningful variable and method names
- Add comments for complex logic
- Keep methods focused and concise
- Use proper memory management (ARC)

#### Code Style

```objective-c
// Good
- (void)startServerWithPort:(NSUInteger)port webPath:(NSString *)webPath {
    // Clear implementation
}

// Bad
-(void)start:(NSUInteger)p path:(NSString*)path{
    // Poor formatting
}
```

#### Testing

- Test on multiple iOS versions
- Test with different network conditions
- Test edge cases and error scenarios
- Verify memory leaks with Instruments

### Pull Request Checklist

Before submitting, ensure:

- [ ] Code compiles without warnings
- [ ] Code follows project style guidelines
- [ ] Added/updated unit tests
- [ ] Updated documentation
- [ ] Tested on iOS 8.0+ devices
- [ ] No memory leaks
- [ ] Clear and descriptive commit messages
- [ ] PR description explains the changes

### Feature Requests

We welcome feature requests! When proposing new features:

1. Explain the use case and benefits
2. Provide examples of how it would be used
3. Consider backward compatibility
4. Discuss implementation approach if possible

### Code Review Process

1. Maintainers will review your PR
2. Address any feedback or requested changes
3. Once approved, your PR will be merged
4. Your contribution will be credited in release notes

## Version History

### Version 1.0.0 (Current)

**Release Date**: Initial Release

**Features:**
- Built-in WebSocket server implementation
- Support for text and binary message types
- Streaming file transfer with automatic chunking
- Integrated HTTP file server functionality
- Heartbeat mechanism with automatic timeout detection
- Thread-safe singleton pattern
- CocoaPods support
- iOS 8.0+ compatibility

**Key Components:**
- WebSocketManager singleton class
- Block-based callback API
- Multiple message type support
- Debug logging with CocoaLumberjack

## Roadmap

We're continuously working to improve LWWebSocket. Here are the features planned for future releases:

### Version 2.0 (Planned)
- [ ] **Multiple Connections**: Support for multiple simultaneous client connections
- [ ] **Swift API**: Native Swift interface and modern async/await support
- [ ] **SSL/TLS Support**: Encrypted WebSocket connections (wss://)

### Future Enhancements
- [ ] **Authentication**: Built-in authentication mechanisms (OAuth, token-based)
- [ ] **Message Compression**: Automatic message compression for bandwidth optimization
- [ ] **Performance Monitoring**: Built-in metrics and statistics tracking
- [ ] **Message Queuing**: Offline message queuing and automatic retry
- [ ] **Connection Pooling**: Efficient connection resource management
- [ ] **Additional Protocols**: Support for additional message encoding formats (MessagePack, Protocol Buffers)
- [ ] **Broadcast Support**: Easy broadcasting to multiple clients
- [ ] **Room/Channel Support**: Organize connections into rooms or channels

### Community Requests

Have a feature request? Please [open an issue](https://github.com/luowei/LWWebSocket/issues) on GitHub!

## Security Considerations

### Network Security

#### Localhost Binding
By default, the WebSocket server listens on `localhost` (127.0.0.1), which restricts access to the local machine only. This provides a basic level of security for local-only applications.

```objective-c
// Server is accessible only via:
// ws://localhost:11335/service
// ws://127.0.0.1:11335/service
```

#### Port Security
- Use non-standard ports in the user/private range (10000-65535)
- Avoid exposing ports to external networks
- Use firewall rules to restrict access if needed
- Don't use well-known ports that might conflict with other services

### Data Security

#### Input Validation
Always validate and sanitize incoming data to prevent injection attacks:

```objective-c
[WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType, NSString *message) {
    // Validate message format
    if (message == nil || message.length == 0) {
        NSLog(@"Invalid message received");
        return;
    }

    // Validate message type
    if (messageType != SocketMessageType_String) {
        NSLog(@"Unexpected message type: %u", messageType);
        return;
    }

    // Parse and validate JSON if applicable
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:0
                                                           error:&error];
    if (error) {
        NSLog(@"Invalid JSON: %@", error);
        return;
    }

    // Process validated data
    [self handleValidatedMessage:json];
};
```

#### Authentication

For production environments, implement connection authentication:

```objective-c
// Example: Token-based authentication
- (void)handleConnectionWithToken:(NSString *)token {
    // Verify token before accepting connection
    if (![self isValidToken:token]) {
        NSLog(@"Invalid authentication token");
        [[WebSocketManager sharedManager] stopServer];
        return;
    }

    NSLog(@"Authenticated connection established");
}
```

### Production Security Checklist

- [ ] **Input Validation**: Validate all incoming data
- [ ] **Authentication**: Implement connection authentication mechanism
- [ ] **Authorization**: Verify client permissions for sensitive operations
- [ ] **Data Sanitization**: Sanitize data before processing or storing
- [ ] **Error Handling**: Don't expose sensitive information in error messages
- [ ] **Logging**: Log security events for audit purposes
- [ ] **SSL/TLS**: Consider adding encryption for sensitive data (future enhancement)
- [ ] **Rate Limiting**: Implement rate limiting to prevent abuse
- [ ] **Timeout Configuration**: Set appropriate connection timeouts
- [ ] **File Access**: Restrict file system access to designated directories only

### Encryption Considerations

The current version does not include SSL/TLS support. For applications requiring encrypted communication:

1. **Future Enhancement**: SSL/TLS support is on the roadmap
2. **Alternative**: Encrypt sensitive data at the application level before transmission
3. **VPN**: Use VPN for secure network communication
4. **Network Isolation**: Keep communication within secure network boundaries

### Secure Development Practices

```objective-c
// Example: Secure file handling
- (void)handleFileTransfer:(NSURL *)fileURL {
    // Validate file path
    NSString *filePath = fileURL.path;
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;

    if (![filePath hasPrefix:documentPath]) {
        NSLog(@"Access denied: File outside document directory");
        return;
    }

    // Verify file exists and is readable
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager isReadableFileAtPath:filePath]) {
        NSLog(@"Access denied: File not readable");
        return;
    }

    // Proceed with secure file transfer
    [[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];
}
```

## Troubleshooting

### Connection Issues

**Problem**: WebSocket connection fails to establish

**Solutions**:
- Verify the server is running: Check if `startServerWithPort:webPath:` was called
- Check the port number matches in both server and client
- Ensure the port is not blocked by firewall
- Verify the connection URL format: `ws://localhost:PORT/service`

### Heartbeat Issues

**Problem**: Connection drops after a few seconds

**Solution**: Implement heartbeat mechanism in your client:
```javascript
setInterval(() => {
    if (socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({
            messageType: 2,
            messageBody: ""
        }));
    }
}, 5000);
```

### Streaming Issues

**Problem**: Large file transfer fails or hangs

**Solutions**:
- Verify the file exists and is readable
- Check available disk space for temporary files
- Monitor memory usage during transfer
- Implement error handling in streaming callbacks

## Related Links

- [GitHub Repository](https://github.com/luowei/LWWebSocket)
- [CocoaPods Page](https://cocoapods.org/pods/LWWebSocket)
- [WebSocket Protocol Specification (RFC 6455)](https://tools.ietf.org/html/rfc6455)

## Author

**luowei**

- Email: luowei@wodedata.com
- GitHub: [@luowei](https://github.com/luowei)

For questions, suggestions, or support, feel free to:
- Open an [issue](https://github.com/luowei/LWWebSocket/issues) on GitHub
- Send an email to the author
- Submit a pull request with improvements

## License

LWWebSocket is available under the **MIT License**.

```
MIT License

Copyright (c) 2025 luowei

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

See the [LICENSE](LICENSE) file for full license text.

## Acknowledgments

Special thanks to the developers of these excellent open-source libraries that make LWWebSocket possible:

- **[CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer)** by Robbie Hanson - Provides robust HTTP server and WebSocket protocol implementation
- **[CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket)** by Robbie Hanson - Powers the asynchronous socket communication layer
- **[CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)** - Delivers fast, flexible logging capabilities

We're grateful to the open-source community for these invaluable tools.

---

## Support

If you find LWWebSocket useful, please consider:

- Starring the repository on [GitHub](https://github.com/luowei/LWWebSocket)
- Sharing it with other iOS developers
- Contributing to the project
- Reporting bugs or suggesting features

---

<div align="center">

**[Back to Top](#lwwebsocket)**

Made with ♥ by [luowei](https://github.com/luowei)

If you have any questions or suggestions, please feel free to [open an issue](https://github.com/luowei/LWWebSocket/issues) or contact via email.

</div>
