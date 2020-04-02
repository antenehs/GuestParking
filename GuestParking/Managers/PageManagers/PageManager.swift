//
//  PageManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 10/21/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import Foundation
import WebKit

// MARK: - FieldKey protocol

protocol FieldKey: RawRepresentable, CaseIterable, MirrorableEnum {
    var fieldId: String { get }
    var modelProperty: String { get }
}

extension FieldKey {
    var modelProperty: String { return caseName }
}

extension FieldKey where RawValue == String {
    var fieldId: String { return rawValue }
}

// MARK: - PageManager protocol

protocol PageManager: class {

    associatedtype HostDetailFields: FieldKey
    associatedtype GuestDetailFields: FieldKey

    var isManualEntry: Bool { get }
    var isManualSaving: Bool { get }
    var webView: WKWebView { get }
    var websiteEntryUrl: String { get }

    var guest: Guest? { get set }
    var host: Host? { get set }

    func startGuestCheckIn(_ guest: Guest?)
    func fillDetails()
    func saveForm(completion: @escaping (Bool) -> Void)
    func completedCheckingIn(_ guest: Guest)
}

// MARK: -
extension PageManager {
    var isManualEntry: Bool { return false }

    var isManualSaving: Bool { return false }

    func startGuestCheckIn(_ guest: Guest?) {
        self.guest = guest
        self.host = guest?.host ?? HostManager.shared.latestHost()

        let url = URL(string: websiteEntryUrl)!

        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }

    func fillHostDetails(_ host: Host) {
        guard let hostDictionary = host.toDictionary() as? [String: Any] else { return }

        HostDetailFields.allCases.forEach { fieldKey in
            webView.setValue(hostDictionary[fieldKey.modelProperty] as? String ?? "", toFieldWithId: fieldKey.fieldId)
        }
    }

    func fillGuestDetails(_ guest: Guest) {
        guard let guestDictionary = guest.toDictionary() as? [String: Any] else { return }

        GuestDetailFields.allCases.forEach { fieldKey in
            webView.setValue(guestDictionary[fieldKey.modelProperty] as? String ?? "", toFieldWithId: fieldKey.fieldId)
        }
    }

    func saveForm(completion: @escaping (Host?, Guest?) -> Void) {

        var guestDictionary = [String: String]()
        var hostDictionary = [String: String]()

        let group = DispatchGroup()

        GuestDetailFields.allCases.forEach { [weak self] fieldKey in
            guard let self = self else { return }
            group.enter()
            self.webView.evaluateJavaScript("document.getElementById('\(fieldKey.fieldId)').value") { value, _ in
                guestDictionary[fieldKey.modelProperty] = value as? String ?? ""
                group.leave()
            }
        }

        HostDetailFields.allCases.forEach { [weak self] fieldKey in
            guard let self = self else { return }
            group.enter()
            self.webView.evaluateJavaScript("document.getElementById('\(fieldKey.fieldId)').value") { value, _ in
                hostDictionary[fieldKey.modelProperty] = value as? String ?? ""
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(Host(dictionary: hostDictionary),
                       Guest(dictionary: guestDictionary))
        }

    }

    func fillDetails() {}

    func completedCheckingIn(_ guest: Guest) {
        if guest.activePassExpiryDate != nil,
            SettingsManager.remindExpiredPassed {
            NotificationManager.scheduleNotification(for: guest)
        }
    }
}
