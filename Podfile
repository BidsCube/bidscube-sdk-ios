platform :ios, '14.0'
use_frameworks!

target 'testApp-ios' do
  pod 'AppLovinSDK', '>= 13.0.0', '< 14.0'
  pod 'BidscubeSDKAppLovin', :git => 'https://github.com/BidsCube/AppLovin-SDK-for-BidsCube-iOS.git', :branch => 'main'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      if target.name == 'BidscubeSDKAppLovin'
        swift_flags = config.build_settings['OTHER_SWIFT_FLAGS'] || '$(inherited)'
        swift_flags = [swift_flags] unless swift_flags.is_a?(Array)
        swift_flags += ['-module-alias', 'BidscubeSDK=BidscubeSDKAppLovin']
        config.build_settings['OTHER_SWIFT_FLAGS'] = swift_flags
        config.build_settings['EXCLUDED_SOURCE_FILE_NAMES'] = 'bidscubeSdk/Tests/*.swift bidscubeSdk/Views/ContentView.swift bidscubeSdk/Views/SDKTestView.swift'
      end
    end
  end
end
