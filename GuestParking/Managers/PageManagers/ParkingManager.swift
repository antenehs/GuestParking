//
//  ParkingManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 10/21/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import Foundation
import WebKit

protocol PageManager: class {

    var isDetailsPage: Bool { get }
    var webView: WKWebView! { get }

    init(webView: WKWebView)

    func checkGuestIn(_ guest: Guest?, completion: (Bool) -> Void)
    func completedCheckingIn(_ guest: Guest)
}

extension PageManager {

    func setValue(_ value: String, toFieldWithId id: String) {
        webView.evaluateJavaScript("document.getElementById('\(id)').value = '\(value)'") { _, _ in }
    }

    func getValue(forId id: String, completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("document.getElementById('\(id)').value") { value, _ in
            completion(value as? String ?? "")
        }
    }

    func clickFirstButton(forName name: String) {
        webView.evaluateJavaScript("document.getElementsByName('\(name)')[0].click()") { _, _ in }
    }

    func clickFirstButton(forClass elementClass: String) {
        webView.evaluateJavaScript("document.getElementsByClassName('\(elementClass)')[0].click()") { _, _ in }
    }

    func getPageSource(completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("document.documentElement.innerHTML") { (html, error) in
            completion(html as? String)
        }
    }

    func completedCheckingIn(_ guest: Guest) {
        if guest.activePassExpiryDate != nil,
            SettingsManager.remindExpiredPassed {
            NotificationManager.scheduleNotification(for: guest)
        }
    }
}
