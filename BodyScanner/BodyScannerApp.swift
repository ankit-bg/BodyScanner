//
//  BodyScannerApp.swift
//  BodyScanner
//
//  Created by Ankit Kumar on 2023/10/04.
//

import SwiftUI
import WebKit

@main
struct BodyScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ScannerView()
        }
    }
}

struct ScannerView: UIViewRepresentable {
        
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        // Configuration.
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController.add(context.coordinator, name: "BGScanflowJSWebviewInterface")
        
        // Webview
        let webview = WKWebView(frame: .zero, configuration: configuration)
        webview.navigationDelegate = context.coordinator
        webview.uiDelegate = context.coordinator
        
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let url = URL(string: "https://platform.bodygram.com/org_id/scan?token=token&screens=scan") // <- Update URL.
        let request = URLRequest(url: url!)
        uiView.load(request)
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
        
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            decisionHandler(.grant)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Handle messages received from JavaScript
            if let messageBody = message.body as? [String: String] {
                parent.onMessageReceived(messageBody)
            }
        }
    }
    
}
