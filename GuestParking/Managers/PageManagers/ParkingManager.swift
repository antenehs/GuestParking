//
//  ParkingManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 10/21/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import Foundation
import WebKit

protocol MirrorableEnum {}
extension MirrorableEnum {
    var mirror: (label: String, params: [String: Any]) {
        get {
            let reflection = Mirror(reflecting: self)
            guard reflection.displayStyle == .enum,
                let associated = reflection.children.first else {
                    return ("\(self)", [:])
            }
            let values = Mirror(reflecting: associated.value).children
            var valuesArray = [String: Any]()
            for case let item in values where item.label != nil {
                valuesArray[item.label!] = item.value
            }
            return (associated.label!, valuesArray)
        }
    }
}

protocol FieldKey: RawRepresentable, CaseIterable, MirrorableEnum {
    var fieldId: String { get }
    var modelProperty: String { get }
}

extension FieldKey {
    var caseName: String { return mirror.label }
    var modelProperty: String { return caseName }
}

extension FieldKey where RawValue == String {
    var fieldId: String { return self.rawValue }
}



protocol PageManager: class {

    associatedtype HostDetailFields: FieldKey
    associatedtype GuestDetailFields: FieldKey

    var isDetailsPage: Bool { get }
    var webView: WKWebView! { get }

    init(webView: WKWebView)

    func checkGuestIn(_ guest: Guest?, completion: (Bool) -> Void)
    func saveForm(completion: @escaping (Bool) -> Void)
    func completedCheckingIn(_ guest: Guest)
}

// MARK: -
extension PageManager {

    func fillHostDetails(_ host: Host) {
        guard let hostDictionary = host.toDictionary() as? [String: Any] else { return }

        HostDetailFields.allCases.forEach { fieldKey in
            setValue(hostDictionary[fieldKey.modelProperty] as? String ?? "", toFieldWithId: fieldKey.fieldId)
        }
    }

    func fillGuestDetails(_ guest: Guest) {
        guard let guestDictionary = guest.toDictionary() as? [String: Any] else { return }

        GuestDetailFields.allCases.forEach { fieldKey in
            setValue(guestDictionary[fieldKey.modelProperty] as? String ?? "", toFieldWithId: fieldKey.fieldId)
        }
    }

    func saveForm(completion: @escaping (Host?, Guest?) -> Void) {

        var guestDictionary = [String: String]()
        var hostDictionary = [String: String]()

        let group = DispatchGroup()

        GuestDetailFields.allCases.forEach { fieldKey in
            group.enter()
            self.webView.evaluateJavaScript("document.getElementById('\(fieldKey.fieldId)').value") { value, _ in
                guestDictionary[fieldKey.modelProperty] = value as? String ?? ""
                group.leave()
            }
        }

        HostDetailFields.allCases.forEach { fieldKey in
            group.enter()
            self.webView.evaluateJavaScript("document.getElementById('\(fieldKey.fieldId)').value") { value, _ in
                hostDictionary[fieldKey.modelProperty] = value as? String ?? ""
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(Host.initFrom(dictionary: hostDictionary),
                       Guest.initFrom(dictionary: guestDictionary))
        }

    }

    func completedCheckingIn(_ guest: Guest) {
        if guest.activePassExpiryDate != nil,
            SettingsManager.remindExpiredPassed {
            NotificationManager.scheduleNotification(for: guest)
        }
    }
}

// MARK: - HTML helpers
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
}
