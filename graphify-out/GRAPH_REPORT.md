# Graph Report - /Users/luowei/projects/libs/LWWebSocket  (2026-05-04)

## Corpus Check
- 82 files · ~95,334 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 847 nodes · 834 edges · 36 communities detected
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 10 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 36|Community 36]]

## God Nodes (most connected - your core abstractions)
1. `GCDAsyncSocket` - 168 edges
2. `HTTPConnection` - 60 edges
3. `HTTPServer` - 42 edges
4. `DDAbstractDatabaseLogger` - 32 edges
5. `WebSocket` - 27 edges
6. `DDLog` - 23 edges
7. `DDLogFileInfo` - 23 edges
8. `DDTTYLogger` - 22 edges
9. `HTTPAsyncFileResponse` - 19 edges
10. `DDFileLogger` - 18 edges

## Surprising Connections (you probably didn't know these)
- `WSLog()` --calls--> `string`  [INFERRED]
  LWWebSocket_swift/MyWebSocket.swift → LWWebSocket_swift/LWSocketMessageType.swift

## Communities (54 total, 0 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.01
Nodes (168): GCDAsyncSocket, -acceptOnInterfaceporterror, -acceptOnPorterror, -addStreamsToRunLoop, -autoDisconnectOnClosedReadStream, -badConfigError, -badParamError, -cf_abortSSLHandshake (+160 more)

### Community 1 - "Community 1"
Cohesion: 0.03
Nodes (59): HTTPConnection, -addBasicAuthChallenge, -addDigestAuthChallenge, -chunkedTransferFooter, -chunkedTransferSizeLineForLength, -continueSendingMultiRangeResponseBody, -continueSendingSingleRangeResponseBody, -continueSendingStandardResponseBody (+51 more)

### Community 2 - "Community 2"
Cohesion: 0.04
Nodes (46): GCDAsyncReadPacket, -ensureCapacityForAdditionalDataOfLength, -initWithDatastartOffsetmaxLengthtimeoutreadLengthterminatortag, -optimalReadLengthWithDefaultshouldPreBuffer, -readLengthForNonTermWithHint, -readLengthForTermWithHintshouldPreBuffer, -readLengthForTermWithPreBufferfound, -searchForTermAfterPreBuffering (+38 more)

### Community 3 - "Community 3"
Cohesion: 0.05
Nodes (34): MyHTTPConnection, -webSocketForURI, MyWebSocket, -dealloc, -startHeartBeatRecvTimer, -stopHeartBeatRecvTimer, -timerHandle, HTTPConfig (+26 more)

### Community 4 - "Community 4"
Cohesion: 0.05
Nodes (41): HTTPServer, -addWebSocket, -bonjourThread, -config, -connectionClass, -connectionDidDie, -dealloc, -documentRoot (+33 more)

### Community 5 - "Community 5"
Cohesion: 0.06
Nodes (31): DDAbstractDatabaseLogger, -createAndStartDeleteTimer, -createSuspendedSaveTimer, -db_delete, -db_log, -db_save, -db_saveAndDelete, -dealloc (+23 more)

### Community 6 - "Community 6"
Cohesion: 0.09
Nodes (14): LWSocketMessageType, data, heartBeat, hello, raw, streamEnd, streaming, streamStart (+6 more)

### Community 7 - "Community 7"
Cohesion: 0.07
Nodes (26): WebSocket, -dealloc, -delegate, -didClose, -didOpen, -didReceiveData, -didReceiveMessage, -initWithRequestsocket (+18 more)

### Community 8 - "Community 8"
Cohesion: 0.08
Nodes (25): DDTTYLogger, -clearAllColors, -clearColorsForAllFlags, -clearColorsForAllTags, -clearColorsForFlag, -clearColorsForFlagcontext, -clearColorsForTag, -codeIndexForColor (+17 more)

### Community 9 - "Community 9"
Cohesion: 0.08
Nodes (21): DDLogFileFormatterDefault, -formatLogMessage, -init, -initWithDateFormatter, DDLogFileManagerDefault, -createNewLogFile, -dealloc, -defaultLogsDirectory (+13 more)

### Community 10 - "Community 10"
Cohesion: 0.09
Nodes (23): DDLog, -addLogger, -applicationWillTerminate, -flushLog, -initialize, -isRegisteredClass, -loggingQueue, -loglevelflagcontextfilefunctionlinetagformat (+15 more)

### Community 11 - "Community 11"
Cohesion: 0.09
Nodes (23): DDLogFileInfo, -addExtendedAttributeWithName, -addExtensionAttributeWithName, -age, -creationDate, -description, -fileAttributes, -fileName (+15 more)

### Community 12 - "Community 12"
Cohesion: 0.1
Nodes (20): DDAbstractLogger, -dealloc, -init, -isOnGlobalLoggingQueue, -isOnInternalLoggerQueue, -logFormatter, -loggerName, -loggerQueue (+12 more)

### Community 13 - "Community 13"
Cohesion: 0.11
Nodes (17): HTTPMessage, -allHeaderFields, -appendData, -body, -dealloc, -headerField, -initEmptyRequest, -initRequestWithMethodURLversion (+9 more)

### Community 14 - "Community 14"
Cohesion: 0.11
Nodes (18): HTTPAsyncFileResponse, -abort, -cancelReadSource, -connectionDidClose, -contentLength, -dealloc, -filePath, -initWithFilePathforConnection (+10 more)

### Community 15 - "Community 15"
Cohesion: 0.13
Nodes (8): ConnectionStatus, connected, connecting, disconnected, failed, View, WebSocketObservable, ObservableObject

### Community 16 - "Community 16"
Cohesion: 0.11
Nodes (18): DDFileLogger, -currentLogFileHandle, -currentLogFileInfo, -dealloc, -init, -initWithLogFileManager, -loggerName, -logMessage (+10 more)

### Community 17 - "Community 17"
Cohesion: 0.12
Nodes (15): HTTPAuthenticationRequest, -base64Credentials, -cnonce, -initWithRequest, -isBasic, -isDigest, -nc, -nonce (+7 more)

### Community 18 - "Community 18"
Cohesion: 0.12
Nodes (15): KeyboardViewController, -conwsBtnAction, -getBtnAction, -handleWithBody, -lexiconBtnAction, -sendWSBtnAction, -textDidChange, -textWillChange (+7 more)

### Community 19 - "Community 19"
Cohesion: 0.12
Nodes (16): WebSocketManager, -constructDataWithMessageType, -dataStream, -myURI, -sendActiveBinaryData, -sendData, -sendDataWithFileURL, -sendMessage (+8 more)

### Community 20 - "Community 20"
Cohesion: 0.17
Nodes (10): HTTPRedirectResponse, -contentLength, -dealloc, -httpHeaders, -initWithPath, -isDone, -offset, -readDataOfLength (+2 more)

### Community 21 - "Community 21"
Cohesion: 0.2
Nodes (6): CustomStringConvertible, LWSocketMessageType, WebSocketExampleView, WebSocketExampleView_Previews, PreviewProvider, View

### Community 22 - "Community 22"
Cohesion: 0.18
Nodes (9): DispatchQueueLogFormatter, -didAddToLogger, -formatLogMessage, -init, -queueThreadLabelForLogMessage, -replacementStringForQueueLabel, -setReplacementStringforQueueLabel, -stringFromDate (+1 more)

### Community 23 - "Community 23"
Cohesion: 0.18
Nodes (10): MultipartFormDataParser, -appendData, -decodedDataFromDataencoding, -decodedDataFromQuotedPrintableData, -findContentEndfromOffset, -findHeaderEndfromOffset, -initWithBoundaryformEncoding, -numberOfBytesToLeavePendingWithDatalengthencoding (+2 more)

### Community 24 - "Community 24"
Cohesion: 0.2
Nodes (8): HTTPErrorResponse(), -contentLength, -initWithErrorCode, -isDone, -offset, -readDataOfLength, -setOffset, -status

### Community 25 - "Community 25"
Cohesion: 0.2
Nodes (8): HTTPDataResponse(), -contentLength, -dealloc, -initWithData, -isDone, -offset, -readDataOfLength, -setOffset

### Community 26 - "Community 26"
Cohesion: 0.25
Nodes (7): LWAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

### Community 27 - "Community 27"
Cohesion: 0.29
Nodes (6): LWViewController, -btn01Action, -btn02Action, -btn03Action, -loadWSWebView, -viewDidLoad

### Community 28 - "Community 28"
Cohesion: 0.29
Nodes (6): DDASLLogger, -init, -initialize, -loggerName, -logMessage, -sharedInstance

### Community 29 - "Community 29"
Cohesion: 0.29
Nodes (6): NSData, -base64Decoded, -base64Encoded, -hexStringValue, -md5Digest, -sha1Digest

### Community 30 - "Community 30"
Cohesion: 0.33
Nodes (5): UIWindow, -canBecomeFirstResponder, -motionBeganwithEvent, -motionCancelledwithEvent, -motionEndedwithEvent

### Community 31 - "Community 31"
Cohesion: 0.33
Nodes (4): MultipartMessageHeaderField(), -description, -initWithDatacontentEncoding, -parseHeaderValueByteslengthencoding

### Community 32 - "Community 32"
Cohesion: 0.33
Nodes (5): NSNumber, -parseStringintoNSInteger, -parseStringintoNSUInteger, -parseStringintoSInt64, -parseStringintoUInt64

### Community 33 - "Community 33"
Cohesion: 0.4
Nodes (4): Tests, -setUp, -tearDown, -testExample

### Community 34 - "Community 34"
Cohesion: 0.4
Nodes (3): MultipartMessageHeader, -description, -initWithDataformEncoding

### Community 36 - "Community 36"
Cohesion: 0.4
Nodes (4): NSValue, -ddrangeCompare, -ddrangeValue, -valueWithDDRange

## Knowledge Gaps
- **670 isolated node(s):** `raw`, `hello`, `heartBeat`, `streamStart`, `streaming` (+665 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `GCDAsyncSocket` connect `Community 0` to `Community 2`?**
  _High betweenness centrality (0.206) - this node is a cross-community bridge._
- **Why does `WebSocketManager` connect `Community 6` to `Community 2`?**
  _High betweenness centrality (0.198) - this node is a cross-community bridge._
- **Why does `HTTPServer` connect `Community 4` to `Community 3`, `Community 6`?**
  _High betweenness centrality (0.118) - this node is a cross-community bridge._
- **What connects `raw`, `hello`, `heartBeat` to the rest of the system?**
  _670 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.01 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._