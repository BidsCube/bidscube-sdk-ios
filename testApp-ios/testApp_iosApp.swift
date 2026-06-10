//
//  testApp_iosApp.swift
//  testApp-ios
//

import SwiftUI
#if canImport(AppLovinSDK)
import AppLovinSDK
#endif

@main
struct testApp_iosApp: App {
    init() {
        initializeMaxSdkIfPossible()
    }

    var body: some Scene {
        WindowGroup {
            TestAppRootView()
        }
    }

    private func initializeMaxSdkIfPossible() {
        #if canImport(AppLovinSDK)
        guard let sdkClass = NSClassFromString("ALSdk") as? NSObject.Type else {
            return
        }

        let sharedSelector = NSSelectorFromString("shared")
        guard
            sdkClass.responds(to: sharedSelector),
            let shared = sdkClass.perform(sharedSelector)?.takeUnretainedValue() as? NSObject
        else {
            return
        }

        let setMediationProviderSelector = NSSelectorFromString("setMediationProvider:")
        if shared.responds(to: setMediationProviderSelector) {
            _ = shared.perform(setMediationProviderSelector, with: "max")
        }

        let initializeWithHandlerSelector = NSSelectorFromString("initializeSdkWithCompletionHandler:")
        if shared.responds(to: initializeWithHandlerSelector) {
            _ = shared.perform(initializeWithHandlerSelector, with: nil)
            return
        }

        let initializeSelector = NSSelectorFromString("initializeSdk")
        if shared.responds(to: initializeSelector) {
            _ = shared.perform(initializeSelector)
        }
        #endif
    }
}
