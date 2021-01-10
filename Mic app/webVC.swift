//
//  webVC.swift
//  Mic app
//
//  Created by admin on 1/8/21.
//  Copyright © 2021 admin. All rights reserved.
//

import UIKit
import WebKit

class webVC: UIViewController,WKNavigationDelegate,WKUIDelegate {
  @IBOutlet var webvw: WKWebView!
  var texttobeSearched = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        webvw.navigationDelegate = self
      loadview(text: texttobeSearched)

        // Do any additional setup after loading the view.
    }
  
  func loadview(text:String){
    let url = URL(string: "\(text)")!
    webvw.load(URLRequest(url: url))
    webvw.allowsBackForwardNavigationGestures = true
  }
  
}
