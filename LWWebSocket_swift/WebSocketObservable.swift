//
//  WebSocketObservable.swift
//  LWWebSocket
//
//  Created by Swift Version Conversion
//  Copyright © 2024. All rights reserved.
//

import SwiftUI
import Combine

/// Observable wrapper for WebSocketManager to enable SwiftUI reactive integration
@available(iOS 13.0, *)
public class WebSocketObservable: ObservableObject {

    // MARK: - Published Properties

    @Published public private(set) var isServerRunning: Bool = false
    @Published public private(set) var lastReceivedMessage: (type: UInt32, message: String)?
    @Published public private(set) var lastReceivedData: (type: UInt32, data: Data?)?
    @Published public private(set) var connectionStatus: ConnectionStatus = .disconnected

    // MARK: - Connection Status

    public enum ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case failed(Error)
    }

    // MARK: - Properties

    private let manager = WebSocketManager.shared

    // MARK: - Initialization

    public init() {
        setupCallbacks()
    }

    // MARK: - Setup

    private func setupCallbacks() {
        manager.handleReceiveMessage = { [weak self] messageType, message in
            DispatchQueue.main.async {
                self?.lastReceivedMessage = (messageType, message)
            }
        }

        manager.handleReceiveData = { [weak self] messageType, data in
            DispatchQueue.main.async {
                self?.lastReceivedData = (messageType, data)
            }
        }
    }

    // MARK: - Server Management

    /// Start the WebSocket server
    /// - Parameters:
    ///   - port: Port number to listen on
    ///   - webPath: Web root directory path
    public func startServer(port: UInt16, webPath: String) {
        manager.startServer(port: port, webPath: webPath)
        DispatchQueue.main.async {
            self.isServerRunning = true
            self.connectionStatus = .connecting
        }
    }

    /// Stop the WebSocket server
    public func stopServer() {
        manager.stopServer()
        DispatchQueue.main.async {
            self.isServerRunning = false
            self.connectionStatus = .disconnected
        }
    }

    // MARK: - Sending Methods

    /// Send a text message
    /// - Parameter message: The message to send
    /// - Returns: Success status
    @discardableResult
    public func sendMessage(_ message: String) -> Bool {
        return manager.sendMessage(message)
    }

    /// Send binary data
    /// - Parameter data: The data to send
    /// - Returns: Success status
    @discardableResult
    public func sendData(_ data: Data) -> Bool {
        return manager.sendData(data)
    }

    /// Send file data
    /// - Parameter fileURL: URL of the file to send
    /// - Returns: Success status
    @discardableResult
    public func sendData(withFileURL fileURL: URL) -> Bool {
        return manager.sendData(withFileURL: fileURL)
    }

    // MARK: - Custom Callbacks

    /// Set custom message handler
    /// - Parameter handler: Closure to handle received messages
    public func onReceiveMessage(_ handler: @escaping (UInt32, String) -> Void) {
        manager.handleReceiveMessage = { [weak self] messageType, message in
            handler(messageType, message)
            DispatchQueue.main.async {
                self?.lastReceivedMessage = (messageType, message)
            }
        }
    }

    /// Set custom data handler
    /// - Parameter handler: Closure to handle received data
    public func onReceiveData(_ handler: @escaping (UInt32, Data?) -> Void) {
        manager.handleReceiveData = { [weak self] messageType, data in
            handler(messageType, data)
            DispatchQueue.main.async {
                self?.lastReceivedData = (messageType, data)
            }
        }
    }
}

// MARK: - SwiftUI View Modifiers

@available(iOS 13.0, *)
public extension View {
    /// Attach a WebSocket server to this view's lifecycle
    /// - Parameters:
    ///   - observable: The WebSocket observable object
    ///   - port: Port number to listen on
    ///   - webPath: Web root directory path
    /// - Returns: Modified view
    func webSocketServer(_ observable: WebSocketObservable, port: UInt16, webPath: String) -> some View {
        self.onAppear {
            observable.startServer(port: port, webPath: webPath)
        }
        .onDisappear {
            observable.stopServer()
        }
    }
}
