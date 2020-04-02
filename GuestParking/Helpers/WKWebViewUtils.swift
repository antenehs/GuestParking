//
//  WKWebViewUtils.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 4/1/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation
import WebKit

class JavascriptMessageHandler: NSObject, WKScriptMessageHandler {

    var recievedMessage: (Any) -> Void

    init(recievedMessage: @escaping (Any) -> Void) {
        self.recievedMessage = recievedMessage
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        recievedMessage(message.body)
    }
}

extension WKWebView {

    func setValue(_ value: String, toFieldWithId id: String) {
        evaluateJavaScript("document.getElementById('\(id)').value = '\(value)'") { _, _ in }
    }

    func getValue(forId id: String, completion: @escaping (String?) -> Void) {
        evaluateJavaScript("document.getElementById('\(id)').value") { value, _ in
            completion(value as? String ?? "")
        }
    }

    func clickFirstButton(forId id: String) {
        evaluateJavaScript("document.getElementById('\(id)').click()") { _, _ in }
    }

    func clickFirstButton(forName name: String) {
        evaluateJavaScript("document.getElementsByName('\(name)')[0].click()") { _, _ in }
    }

    func clickFirstButton(forClass elementClass: String) {
        evaluateJavaScript("document.getElementsByClassName('\(elementClass)')[0].click()") { _, _ in }
    }

    func getPageSource(completion: @escaping (String?) -> Void) {
        evaluateJavaScript("document.documentElement.innerHTML") { (html, error) in
            completion(html as? String)
        }
    }
}
