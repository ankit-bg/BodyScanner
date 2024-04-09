//
//  Background.swift
//  weather
//
//  Created by Ankit Kumar on 2023/09/18.
//

import SwiftUI
import WebKit


struct ScannerView2: UIViewRepresentable {
        
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.userContentController.add(context.coordinator, name: "BGScanflowJSWebviewInterface")
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let url = URL(string: "https://grghn8cv-3000.asse.devtunnels.ms/scan/scan&screens=scan")
        let request = URLRequest(url: url!)
        uiView.load(request)
    }
    
    func onMessageReceived(_ message: [String: String]) {
        print(message)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: ScannerView2
        
        init(_ webView: ScannerView2) {
            self.parent = webView
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let script = "window.BGScanflowJSWebviewInterface = (type, payload) => window.webkit.messageHandlers.BGScanflowJSWebviewInterface.postMessage({ type, payload })"
            
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Handle messages received from JavaScript
            if let messageBody = message.body as? [String: String] {
                parent.onMessageReceived(messageBody)
            }
        }
    }
    
}
