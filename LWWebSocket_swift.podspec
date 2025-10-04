#
# Be sure to run `pod lib lint LWWebSocket_swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWWebSocket_swift'
  s.version          = '1.0.0'
  s.summary          = 'Swift版本的LWWebSocket - APP内轻量级WebSocket数据传输服务器'

  s.description      = <<-DESC
LWWebSocket_swift 是 LWWebSocket 的 Swift 版本实现。
提供了现代化的 Swift API 用于在 APP 内创建轻量级的 WebSocket 数据传输服务器。
支持 SwiftUI 的响应式编程，包含 WebSocketManager 和 WebSocketObservable。
                       DESC

  s.homepage         = 'https://github.com/luowei/LWWebSocket'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWWebSocket.git', :tag => "swift-#{s.version}" }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'LWWebSocket_swift/**/*.swift'

  s.resource_bundles = {
    'LWWebSocket' => ['LWWebSocket/Assets/**/*']
  }

  s.frameworks = 'Foundation', 'CFNetwork'
  s.libraries = 'xml2'

  s.pod_target_xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '$(inherited) "${PROJECT_DIR}/.."/**  /usr/include/libxml2' }
end
