//
//  MyHTTPConnection.swift
//  LWWebSocket
//
//  Created by Swift Version Conversion
//  Copyright © 2024. All rights reserved.
//

import Foundation

/// Custom HTTP connection handler for WebSocket upgrades
class MyHTTPConnection: HTTPConnection {

    // MARK: - Properties

    var webSocket: MyWebSocket?

    // MARK: - WebSocket Handling

    override func webSocket(forURI path: String) -> WebSocket? {
        guard let myURI = WebSocketManager.shared.myURI else {
            return super.webSocket(forURI: path)
        }

        if path == myURI {
            let socket = MyWebSocket(request: request, socket: asyncSocket)
            socket.uri = path
            socket.delegate = WebSocketManager.shared
            self.webSocket = socket
            return socket
        }

        return super.webSocket(forURI: path)
    }
}
