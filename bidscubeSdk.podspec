Pod::Spec.new do |spec|
  spec.name         = "bidscubeSdk"
  spec.version      = "0.0.1"
  spec.summary      = "BidsCube iOS SDK for displaying ads"
  spec.description  = <<-DESC
                      BidsCube iOS SDK provides a comprehensive solution for displaying image, video, and native ads in iOS applications.
                      The SDK supports various ad formats and positions with easy integration.
                      
                      Features:
                      - Image, Video, and Native ad support
                      - Multiple ad positions (header, footer, sidebar, fullscreen)
                      - VAST video ad support with IMA SDK integration
                      - Banner ad management
                      - Gesture-based navigation controls
                      - Error handling and timeout management
                      DESC

  spec.homepage     = "https://github.com/bidscube/bidscube-sdk-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Vlad" => "generalisimys20132@gmail.com" }
  
  spec.platform     = :ios, "13.0"
  spec.ios.deployment_target = '13.0'
  spec.swift_version = "5.0"
  
  spec.documentation_url = "https://github.com/bidscube/bidscube-sdk-ios"
  
  spec.source       = { :git => "https://github.com/bidscube/bidscube-sdk-ios.git", :tag => "#{spec.version}" }
  
  spec.source_files = "bidscubeSdk/**/*.{swift,h}"
  spec.public_header_files = "bidscubeSdk/bidscubeSdk.h"
  
  spec.dependency 'GoogleAds-IMA-iOS-SDK', '~> 3.19'
  
  spec.frameworks = 'UIKit', 'WebKit', 'AVFoundation', 'MediaPlayer'
  
  spec.requires_arc = true
  
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'SWIFT_VERSION' => '5.0'
  }
  
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  
end
