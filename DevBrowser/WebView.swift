//
//  WebView.swift
//  DevBrowser
//
//  Created by Derrick Goodfriend on 10/24/24.
//

import SwiftUI
@preconcurrency import WebKit

struct WebView: NSViewRepresentable {
    @Binding var url: URL
    @Binding var pageTitle: String
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var webView: WKWebView?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func reloadPage() {
            webView?.reload() // Force reload
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Title might not be updated here, so we rely on KVO
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let newURL = navigationAction.request.url {
                DispatchQueue.main.async {
                    self.parent.url = newURL
                }
            }
            decisionHandler(.allow)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        context.coordinator.webView = webView
        webView.navigationDelegate = context.coordinator
        webView.addObserver(context.coordinator, forKeyPath: "title", options: .new, context: nil)
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if nsView.url != url {
            nsView.load(URLRequest(url: url))
        }
    }
}

extension WebView.Coordinator {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title", let webView = object as? WKWebView {
            if let title = webView.title {
                DispatchQueue.main.async {
                    self.parent.pageTitle = title
                }
            }
        }
    }
}
