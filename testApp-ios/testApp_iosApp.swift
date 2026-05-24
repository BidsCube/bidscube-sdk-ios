//
//  testApp_iosApp.swift
//  testApp-ios
//
//  Created by Vladyslav Humennyi on 09/09/2025.
//

import SwiftUI
import AppLovinSDK
import Foundation

@main
struct testApp_iosApp: App {
    init() {
        initializeMaxSdkIfPossible()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func initializeMaxSdkIfPossible() {
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
    }
}
