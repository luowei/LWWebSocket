# LWWebSocket

[![CI Status](https://img.shields.io/travis/luowei/LWWebSocket.svg?style=flat)](https://travis-ci.org/luowei/LWWebSocket)
[![Version](https://img.shields.io/cocoapods/v/LWWebSocket.svg?style=flat)](https://cocoapods.org/pods/LWWebSocket)
[![License](https://img.shields.io/cocoapods/l/LWWebSocket.svg?style=flat)](https://cocoapods.org/pods/LWWebSocket)
[![Platform](https://img.shields.io/cocoapods/p/LWWebSocket.svg?style=flat)](https://cocoapods.org/pods/LWWebSocket)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```Objective-C
NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
[[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];

[WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType,NSString *message){

    switch (messageType){
        case SocketMessageType_String:{
            NSLog(@"handleReceiveMessage Type:%d,text:%@", messageType, message);
            break;
        }
        default:{
            break;
        }
    }

};

[WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType,NSData *data){
    switch (messageType){
        case SocketMessageType_StreamStart:{
            NSLog(@"handleReceiveMessage StreamStart");
            break;
        }
        case SocketMessageType_Streaming:{
            break;
        }
        case SocketMessageType_StreamEnd:{
            NSString *dataPath = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"handleReceiveMessage StreamEnd, dataPath:%@",dataPath);
            break;
        }
        case SocketMessageType_Data:{
            //handle received binary data
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"handleReceiveData Type:%d,text:%@", messageType, text);
            break;
        }
        default:{
            break;
        }
    }

};

```


## Requirements

## Installation

LWWebSocket is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LWWebSocket'
```

## Author

luowei, luowei@wodedata.com

## License

LWWebSocket is available under the MIT license. See the LICENSE file for more info.
