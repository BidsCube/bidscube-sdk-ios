import SwiftUI
import UIKit

struct UIViewRepresentableWrapper: UIViewRepresentable {
    let view: UIView
    
    func makeUIView(context: Context) -> UIView {
        print("🔍 UIViewRepresentableWrapper: Creating UIView wrapper")
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Ensure the view is properly laid out when updated
        uiView.layoutIfNeeded()
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        print("🔍 UIViewRepresentableWrapper: Dismantling UIView wrapper")
        _ = coordinator
        // Keep wrapper generic for AppLovin views.
    }
}
