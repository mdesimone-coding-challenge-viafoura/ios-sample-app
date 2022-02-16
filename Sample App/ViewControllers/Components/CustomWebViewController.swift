//
//  CustomWebViewController.swift
//  Sample App
//
//  Created by Martin De Simone on 15/02/2022.
//

import Foundation
import UIKit
import WebKit

class CustomWebViewController: UIViewController{
    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
    }
    
    func setupWebView(){
        webView = WKWebView(frame: self.view.bounds)
        view.addSubview(webView!)
    }
    
    func loadUrl(url: URL){
        webView?.load(URLRequest(url: url))
    }
}
