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


final class BGWebView: WKWebView, WKUIDelegate {
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.uiDelegate = self // need to set this delaget in order to access to motion sensor.
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder): has not been implemented")
    }
}

final class BGWebViewConfiguration: WKWebViewConfiguration {
  override init() {
    super.init()
    self.allowsInlineMediaPlayback = true // need to set this to be able to show the camera
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


struct ScannerView: UIViewRepresentable {
        
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = BGWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "BGScanflowJSWebviewInterface")
        let webview = BGWebView(frame: .zero, configuration: configuration)
        webview.navigationDelegate = context.coordinator
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let url = URL(string: "{URL}") // <- Update URL.
        let request = URLRequest(url: url!)
        uiView.load(request)
    }
    
    func onMessageReceived(_ message: [String: String]) {
        print(message)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: ScannerView
        
        init(_ webView: ScannerView) {
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
