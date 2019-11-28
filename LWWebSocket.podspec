#
# Be sure to run `pod lib lint LWWebSocket.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWWebSocket'
  s.version          = '1.0.0'
  s.summary          = 'A short description of LWWebSocket.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    You are welcome ! LWWebSocket Library .
                       DESC

  s.homepage         = 'https://github.com/luowei/LWWebSocket'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWWebSocket.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = [
    'LWWebSocket/Classes/**/*.{h,m,mm}',
    'LWWebSocket/Library/CocoaAsyncSocket/**/*.{h,m,mm}',
    'LWWebSocket/Library/CocoaHTTPServer/**/*.{h,m,mm}',
    'LWWebSocket/Library/CocoaLumberjack/**/*.{h,m,mm}',
  ]
  s.public_header_files = [
    'LWWebSocket/Classes/WebSocketManager.h',
    # 'LWWebSocket/Library/CocoaHTTPServer/HTTPConnection.h',
    # 'LWWebSocket/Library/CocoaHTTPServer/WebSocket.h',
    # 'LWWebSocket/Library/CocoaAsyncSocket/**/*.h',
    # 'LWWebSocket/Library/CocoaHTTPServer/**/*.h',
    # 'LWWebSocket/Library/CocoaLumberjack/**/*.h',
  ]
  
  s.resource_bundles = {
    'LWWebSocket' => ['LWWebSocket/Assets/**/*']
  }
  s.libraries = 'xml2'

  s.pod_target_xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '$(inherited) "${PROJECT_DIR}/.."/**  /usr/include/libxml2' }

  # ss.frameworks = [
  #   'Foundation','CoreGraphics','UIKit','SystemConfiguration','QuartzCore','VideoToolbox','AudioToolbox','AVFoundation','CoreMedia','AssetsLibrary','CFNetwork',
  # ]
  # ss.libraries = 'bz2', 'z', 'iconv'
  # ss.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '$(inherited) -ObjC -lstdc++','ENABLE_BITCODE' => 'NO' }
  # ss.vendored_libraries = [
  #   'LWWebSocket/Libraries/LiveNess/libLFLivenessDetector.a',
  # ]


  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
