//
//  MyWebSocket.swift
//  LWWebSocket
//
//  Created by Swift Version Conversion
//  Copyright © 2024. All rights reserved.
//

import Foundation

#if DEBUG
func WSLog(_ format: String, _ args: CVarArg...) {
    let message = String(format: format, arguments: args)
    print("[\(#file):\(#line)] \(#function)\n\(message)\n\n")
}
#else
func WSLog(_ format: String, _ args: CVarArg...) {}
#endif

/// Custom WebSocket implementation with heartbeat functionality
class MyWebSocket: WebSocket {

    // MARK: - Properties

    var uri: String?

    private var heartBeatRecvTimer: DispatchSourceTimer?
    private var heartBeatRecvQueue: DispatchQueue?

    // MARK: - Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopHeartBeatRecvTimer()
    }

    // MARK: - Heartbeat Management

    /// Start the heartbeat receive timer (8 second timeout)
    func startHeartBeatRecvTimer() {
        stopHeartBeatRecvTimer()

        if heartBeatRecvQueue == nil {
            heartBeatRecvQueue = DispatchQueue(label: "com.wodedata.mobile.heatBeatRecv")
        }

        guard let queue = heartBeatRecvQueue else { return }

        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + 8.0, repeating: .never, leeway: .milliseconds(100))

        timer.setEventHandler { [weak self] in
            self?.timerHandle()
        }

        heartBeatRecvTimer = timer
        timer.resume()
    }

    /// Stop the heartbeat receive timer
    func stopHeartBeatRecvTimer() {
        heartBeatRecvTimer?.cancel()
        heartBeatRecvTimer = nil
    }

    /// Handle timeout - close connection if no heartbeat received
    private func timerHandle() {
        stopHeartBeatRecvTimer()
        stop()
    }
}
