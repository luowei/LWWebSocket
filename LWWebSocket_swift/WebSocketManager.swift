//
//  WebSocketManager.swift
//  LWWebSocket
//
//  Created by Swift Version Conversion
//  Copyright © 2024. All rights reserved.
//

import Foundation

/// Main WebSocket server manager for in-app WebSocket communication
public class WebSocketManager: NSObject {

    // MARK: - Singleton

    public static let shared = WebSocketManager()

    private override init() {
        super.init()
    }

    // MARK: - Properties

    /// Callback for receiving text messages
    public var handleReceiveMessage: ((UInt32, String) -> Void)?

    /// Callback for receiving binary data
    public var handleReceiveData: ((UInt32, Data?) -> Void)?

    private var httpServer: HTTPServer?
    private weak var webSocket: MyWebSocket?

    // Stream properties for file transfer
    private var dataStream: OutputStream?
    private var streamFilePath: String?
    private var streamError: Error?

    // MARK: - Computed Properties

    private var generatedStreamFilePath: String {
        if streamFilePath == nil {
            streamFilePath = NSTemporaryDirectory() + UUID().uuidString
        }
        return streamFilePath!
    }

    private var outputStream: OutputStream {
        if dataStream == nil {
            dataStream = OutputStream(toFileAtPath: generatedStreamFilePath, append: true)
        }
        return dataStream!
    }

    var myURI: String {
        return "/service"
    }

    // MARK: - Server Management

    /// Start the WebSocket server on specified port
    /// - Parameters:
    ///   - port: Port number to listen on
    ///   - webPath: Web root directory path
    public func startServer(port: UInt16, webPath: String) {
        guard httpServer?.isRunning != true else {
            return
        }

        let server = HTTPServer()
        httpServer = server

        // Use custom HTTP connection class
        server.connectionClass = MyHTTPConnection.self

        // Broadcast presence via Bonjour
        server.setType("_http._tcp.")

        // Set port
        server.port = port

        // Setup document root
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        var absWebPath: String

        if webPath.hasPrefix("/var") {
            absWebPath = webPath
        } else {
            absWebPath = (documentPath as NSString).appendingPathComponent(webPath)
        }

        var isDirectory: ObjCBool = false
        let existsWebPath = FileManager.default.fileExists(atPath: absWebPath, isDirectory: &isDirectory)

        if !isDirectory.boolValue || !existsWebPath {
            do {
                try FileManager.default.createDirectory(atPath: absWebPath, withIntermediateDirectories: true, attributes: nil)
                WSLog("Successfully created directory at: %@", absWebPath)
            } catch {
                WSLog("Failed to create directory: %@", error.localizedDescription)
                absWebPath = documentPath
            }
        }

        server.documentRoot = absWebPath

        WSLog("=====webpath:%@", webPath)

        // Start the server
        do {
            try server.start()
        } catch {
            WSLog("start server error:%@", error.localizedDescription)
        }
    }

    /// Stop the WebSocket server
    public func stopServer() {
        if let server = httpServer, server.isRunning {
            server.stop()
        }
    }

    // MARK: - Sending Methods

    /// Send a text message through WebSocket
    /// - Parameter message: The message string to send
    /// - Returns: Success status
    @discardableResult
    public func sendMessage(_ message: String) -> Bool {
        guard let ws = webSocket else {
            return false
        }

        ws.sendMessage(message)
        return true
    }

    /// Send binary data through WebSocket
    /// - Parameter data: The data to send
    /// - Returns: Success status
    @discardableResult
    public func sendData(_ data: Data) -> Bool {
        guard let ws = webSocket else {
            return false
        }

        var sendData = constructData(withMessageType: .data)
        sendData.append(data)
        ws.send(sendData, isBinary: true)

        return true
    }

    /// Send file data through WebSocket using streaming
    /// - Parameter fileURL: URL of the file to send
    /// - Returns: Success status
    @discardableResult
    public func sendData(withFileURL fileURL: URL) -> Bool {
        guard let ws = webSocket else {
            return false
        }

        // Send stream start
        let startData = constructData(withMessageType: .streamStart)
        ws.send(startData, isBinary: true)

        // Read and send file in chunks
        do {
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            defer {
                if #available(iOS 13.0, *) {
                    try? fileHandle.close()
                } else {
                    fileHandle.closeFile()
                }
            }

            while true {
                let data: Data
                if #available(iOS 13.0, *) {
                    guard let chunk = try fileHandle.read(upToCount: 10240), !chunk.isEmpty else {
                        break
                    }
                    data = chunk
                } else {
                    data = fileHandle.readData(ofLength: 10240)
                    if data.isEmpty {
                        break
                    }
                }

                var streamingData = constructData(withMessageType: .streaming)
                streamingData.append(data)
                ws.send(streamingData, isBinary: true)
            }
        } catch {
            WSLog("===error:%@", error.localizedDescription)
        }

        // Send stream end
        let endData = constructData(withMessageType: .streamEnd)
        ws.send(endData, isBinary: true)

        return true
    }

    // MARK: - Helper Methods

    /// Construct data with message type header
    /// - Parameter messageType: The message type to prepend
    /// - Returns: Data with message type header
    private func constructData(withMessageType messageType: LWSocketMessageType) -> Data {
        var data = Data()
        var type = messageType.rawValue
        data.append(Data(bytes: &type, count: MemoryLayout<UInt32>.size))
        return data
    }

    /// Send initial hello message
    private func sendActiveBinaryData() {
        guard let ws = webSocket else { return }

        var data = Data()
        var messageType = LWSocketMessageType.hello.rawValue
        data.append(Data(bytes: &messageType, count: MemoryLayout<UInt32>.size))
        data.append("hello world!".data(using: .utf8)!)

        ws.send(data, isBinary: true)
    }
}

// MARK: - WebSocketDelegate

extension WebSocketManager: WebSocketDelegate {

    public func webSocketDidOpen(_ ws: WebSocket) {
        WSLog("=======%s", #function)

        if let myWs = ws as? MyWebSocket {
            webSocket = myWs
            myWs.startHeartBeatRecvTimer()
        }

        sendActiveBinaryData()
    }

    public func webSocket(_ ws: WebSocket, didReceiveMessage msg: String) {
        WSLog("=======%s", #function)

        guard !msg.isEmpty,
              let data = msg.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return
        }

        WSLog("=======didReceiveMessage msg:%@", msg)

        guard let messageTypeValue = dict["messageType"] as? Int else {
            return
        }

        let messageType = UInt32(messageTypeValue)

        // Handle heartbeat
        if messageType == LWSocketMessageType.heartBeat.rawValue,
           let myWs = ws as? MyWebSocket {
            myWs.startHeartBeatRecvTimer()
            return
        }

        // Handle regular message
        if let messageBody = dict["messageBody"] as? String {
            handleReceiveMessage?(messageType, messageBody)
        }
    }

    public func webSocket(_ ws: WebSocket, didReceiveData data: Data) {
        WSLog("=======%s", #function)

        guard handleReceiveData != nil else {
            return
        }

        let headerLen = 4
        guard data.count >= headerLen else {
            return // Invalid message
        }

        // Extract message type from first 4 bytes
        let headerData = data.subdata(in: 0..<headerLen)
        let messageType = headerData.withUnsafeBytes { $0.load(as: UInt32.self) }

        // Extract real data (after header)
        let realData = data.subdata(in: headerLen..<data.count)

        switch LWSocketMessageType(rawValue: messageType) {
        case .streamStart:
            WSLog("======ws didReceiveData StreamStart")
            outputStream.open()
            handleReceiveData?(messageType, nil)

        case .streaming:
            WSLog("======ws didReceiveData Streaming ...")
            let dataLength = realData.count
            let writeLen = realData.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Int in
                guard let baseAddress = bytes.baseAddress else { return 0 }
                return outputStream.write(baseAddress.assumingMemoryBound(to: UInt8.self), maxLength: dataLength)
            }

            if dataLength > writeLen {
                // Error occurred
                streamFilePath = nil
                streamError = outputStream.streamError
                outputStream.close()
                dataStream = nil
                return
            }
            handleReceiveData?(messageType, nil)

        case .streamEnd:
            WSLog("======ws didReceiveData StreamEnd")
            if let stream = dataStream, stream.streamStatus != .closed {
                stream.close()
                dataStream = nil
            }

            let pathData = streamError == nil ? streamFilePath?.data(using: .utf8) : nil
            handleReceiveData?(messageType, pathData)

        default:
            handleReceiveData?(messageType, realData)
        }
    }

    public func webSocketDidClose(_ ws: WebSocket) {
        WSLog("=======%s", #function)
    }
}
