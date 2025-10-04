//
//  LWSocketMessageType.swift
//  LWWebSocket
//
//  Created by Swift Version Conversion
//  Copyright © 2024. All rights reserved.
//

import Foundation

/// WebSocket message types for different data transmission scenarios
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
