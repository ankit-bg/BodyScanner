//
//  BodyScannerApp.swift
//  BodyScanner
//
//  Created by Ankit Kumar on 2023/10/04.
//

import SwiftUI
import WebKit
import AVFoundation

@main
struct BodyScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ScannerView()
        }
    }
}

struct ScannerView: UIViewRepresentable {
    @State private var cameraPermissionGranted = false
        
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        webview.configuration.allowsInlineMediaPlayback = true
        webview.configuration.userContentController.add(context.coordinator, name: "BGScanflowJSWebviewInterface")
        webview.navigationDelegate = context.coordinator
        webview.uiDelegate = context.coordinator
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: "https://platform.bodygram.com/org_id/scan?token=token&screens=scan") {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [self] granted in
            DispatchQueue.main.async {
                self.cameraPermissionGranted = granted
            }
        }
    }
    
    func onMessageReceived(_ message: [String: String]) {
        print(message)
    }
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: ScannerView
        
        init(_ webView: ScannerView) {
            self.parent = webView
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let script = "window.BGScanflowJSWebviewInterface = (type, payload) => window.webkit.messageHandlers.BGScanflowJSWebviewInterface.postMessage({ type, payload })"
            webView.evaluateJavaScript(script, completionHandler: nil)
            
            
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            if navigationAction.request.url?.scheme == "https" {
                // Handle navigation requests here if necessary
                decisionHandler(.allow, preferences)
            } else {
                decisionHandler(.cancel, preferences)
            }
        }
        
//        @available(iOS 15.0, *)
//        func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
//            decisionHandler(.grant)
//        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Handle messages received from JavaScript
            if let messageBody = message.body as? [String: String] {
                parent.onMessageReceived(messageBody)
            }
        }
    }
    
}
