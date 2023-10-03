//
//  GIFView.swift
//  
//
//  Created by Hetul Soni on 03/10/23.
//

import Foundation
import SwiftUI
import WebKit

struct GIFView: UIViewRepresentable {
    
    public var url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    func makeCoordinator() -> GIFViewCoordinator {
        return GIFViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
//
//        let cssString = """
//                html,
//                body {
//                    width: 100%;
//                    height: 100%;
//                    display: flex;
//                    align-items: center;
//                    justify-content: center;
//                }
//                img {
//                    width: 100%;
//                    height: 100%;
//                }
//                """
//
//        let source = """
//              var style = document.createElement('style');
//              style.innerHTML = '\(cssString)';
//              document.head.appendChild(style);
//            """
        
//        let userScript = WKUserScript(source: source,
//                                      injectionTime: .atDocumentEnd,
//                                      forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
//        userContentController.addUserScript(userScript)
        
        let confing = WKWebViewConfiguration()
        confing.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: confing)
        webView.navigationDelegate = context.coordinator
        if url.isFileURL {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
        else {
            webView.load(URLRequest(url: url))
        }
        webView.isUserInteractionEnabled = false
        webView.scrollView.showsVerticalScrollIndicator = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        
    }
    
}

extension GIFView {
    class GIFViewCoordinator: NSObject, WKNavigationDelegate {
        
        var parent: GIFView
        
        init(_ uiWebView: GIFView) {
            self.parent = uiWebView
        }
        
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
        {
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            
            let cssString = "html,body { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; }"
            let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
            webView.evaluateJavaScript(jsString, completionHandler: nil)
     
        }
        
    }
}
