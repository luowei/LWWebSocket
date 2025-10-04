//
//  WebSocketExampleView.swift
//  LWWebSocket
//
//  Created by Swift Version Conversion
//  Copyright © 2024. All rights reserved.
//

import SwiftUI

/// Example SwiftUI view demonstrating WebSocket usage
@available(iOS 13.0, *)
public struct WebSocketExampleView: View {

    @StateObject private var webSocket = WebSocketObservable()
    @State private var messageToSend = ""
    @State private var receivedMessages: [String] = []

    public init() {}

    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                // Status Section
                statusSection

                // Messages List
                messagesSection

                // Send Message Section
                sendMessageSection

                Spacer()
            }
            .padding()
            .navigationTitle("WebSocket Demo")
        }
        .onAppear {
            setupWebSocket()
        }
    }

    // MARK: - View Components

    private var statusSection: some View {
        VStack(spacing: 10) {
            HStack {
                Circle()
                    .fill(webSocket.isServerRunning ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                Text(webSocket.isServerRunning ? "Server Running" : "Server Stopped")
                    .font(.headline)
            }

            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    private var statusText: String {
        switch webSocket.connectionStatus {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Waiting for connection..."
        case .connected:
            return "Connected"
        case .failed(let error):
            return "Failed: \(error.localizedDescription)"
        }
    }

    private var messagesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Received Messages")
                .font(.headline)

            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(receivedMessages, id: \.self) { message in
                        Text(message)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
        }
    }

    private var sendMessageSection: some View {
        VStack(spacing: 10) {
            Text("Send Message")
                .font(.headline)

            HStack {
                TextField("Enter message", text: $messageToSend)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .disabled(messageToSend.isEmpty || !webSocket.isServerRunning)
            }

            HStack(spacing: 15) {
                Button("Send Test Data") {
                    sendTestData()
                }
                .buttonStyle(.bordered)
                .disabled(!webSocket.isServerRunning)

                Button("Clear Messages") {
                    receivedMessages.removeAll()
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Setup

    private func setupWebSocket() {
        // Start server on port 8080 with a web path
        webSocket.startServer(port: 8080, webPath: "websocket")

        // Setup message handler
        webSocket.onReceiveMessage { messageType, message in
            let displayMessage = "[\(LWSocketMessageType(rawValue: messageType)?.description ?? "Unknown")] \(message)"
            receivedMessages.insert(displayMessage, at: 0)
        }

        // Setup data handler
        webSocket.onReceiveData { messageType, data in
            if let data = data {
                let displayMessage = "[\(LWSocketMessageType(rawValue: messageType)?.description ?? "Unknown")] Received \(data.count) bytes"
                receivedMessages.insert(displayMessage, at: 0)
            }
        }
    }

    // MARK: - Actions

    private func sendMessage() {
        guard !messageToSend.isEmpty else { return }

        let success = webSocket.sendMessage(messageToSend)
        if success {
            receivedMessages.insert("[Sent] \(messageToSend)", at: 0)
            messageToSend = ""
        }
    }

    private func sendTestData() {
        let testData = "Test binary data".data(using: .utf8)!
        let success = webSocket.sendData(testData)
        if success {
            receivedMessages.insert("[Sent] Binary data (\(testData.count) bytes)", at: 0)
        }
    }
}

// MARK: - LWSocketMessageType Extension

@available(iOS 13.0, *)
extension LWSocketMessageType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .raw:
            return "Raw"
        case .hello:
            return "Hello"
        case .heartBeat:
            return "HeartBeat"
        case .streamStart:
            return "StreamStart"
        case .streaming:
            return "Streaming"
        case .streamEnd:
            return "StreamEnd"
        case .string:
            return "String"
        case .data:
            return "Data"
        }
    }
}

// MARK: - Preview

@available(iOS 13.0, *)
struct WebSocketExampleView_Previews: PreviewProvider {
    static var previews: some View {
        WebSocketExampleView()
    }
}
