Pod::Spec.new do |spec|
  spec.name         = "bidscubeSdk"
  spec.version      = "1.2.6"
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
  spec.swift_versions = ['5.9']
  
  spec.documentation_url = "https://github.com/bidscube/bidscube-sdk-ios"
  
  spec.source       = { :git => "https://github.com/bidscube/bidscube-sdk-ios.git", :tag => "v#{spec.version}" }
  
  spec.source_files = "bidscubeSdk/**/*.{swift,h}"
  spec.exclude_files = [
    "bidscubeSdk/Tests/**/*",
    "bidscubeSdk/Controller/ViewController.swift",
    "bidscubeSdk/Controller/WindowedAdTestViewController.swift",
    "bidscubeSdk/Views/ContentView.swift",
    "bidscubeSdk/Views/SDKTestView.swift"
  ]
  spec.public_header_files = "bidscubeSdk/bidscubeSdk.h"
  
  spec.dependency 'GoogleAds-IMA-iOS-SDK', '~> 3.19'
  
  spec.frameworks = 'UIKit', 'WebKit', 'AVFoundation', 'MediaPlayer'
  
  spec.requires_arc = true

  # Standalone for mediation adapters (e.g. AppLovin MAX 13.x): no simulator arch hacks;
  # apps should use the same minimum iOS as AppLovinSDK when integrating both.
  spec.pod_target_xcconfig = {
    'SWIFT_STRICT_CONCURRENCY' => 'off'
  }

  spec.user_target_xcconfig = {
    'SWIFT_STRICT_CONCURRENCY' => 'off'
  }

end
