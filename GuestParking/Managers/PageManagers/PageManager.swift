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

protocol FieldKeys: RawRepresentable, CaseIterable, MirrorableEnum {
    var fieldId: String { get }
    var modelProperty: String { get }
}

extension FieldKeys {
    var modelProperty: String { return caseName }
}

extension FieldKeys where RawValue == String {
    var fieldId: String { return rawValue }
}

// MARK: - PageManager protocol

protocol PageManager: class {

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
        self.guest = guest ?? Guest()
        self.host = guest?.host ?? HostManager.shared.latestHost()

        let url = URL(string: websiteEntryUrl)!

        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }

    func fillHostDetails<Keys: FieldKeys>(_ host: Host, usingKeys keys: Keys.Type) {
        guard let hostDictionary = host.toDictionary() as? [String: Any] else { return }

        keys.allCases.forEach { fieldKey in
            webView.setValue(hostDictionary[fieldKey.modelProperty] as? String ?? "", toFieldWithId: fieldKey.fieldId)
        }
    }

    func fillGuestDetails<Keys: FieldKeys>(_ guest: Guest, usingKeys keys: Keys.Type) {
        guard let guestDictionary = guest.toDictionary() as? [String: Any] else { return }

        keys.allCases.forEach { fieldKey in
            webView.setValue(guestDictionary[fieldKey.modelProperty] as? String ?? "", toFieldWithId: fieldKey.fieldId)
        }
    }

    func saveForm<GuestKeys: FieldKeys, HostKeys: FieldKeys>(using guestKeys: GuestKeys.Type,
                                                             hostKeys: HostKeys.Type,
                                                             completion: @escaping (Host?, Guest?) -> Void) {

        var guestDictionary = [String: String]()
        var hostDictionary = [String: String]()

        let group = DispatchGroup()

        guestKeys.allCases.forEach { [weak self] fieldKey in
            guard let self = self else { return }
            group.enter()
            self.webView.evaluateJavaScript("document.getElementById('\(fieldKey.fieldId)').value") { value, _ in
                guestDictionary[fieldKey.modelProperty] = value as? String ?? ""
                group.leave()
            }
        }

        hostKeys.allCases.forEach { [weak self] fieldKey in
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

        if guest.activePassExpiryDate == nil,
            guest.activePassMessage == nil {

            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"

            var _guest = guest
            _guest.activePassMessage = "Registered on \(dateFormatter.string(from: Date()))"
            _guest.activePassExpiryDate = Date().addingTimeInterval(60 * 60 * 24)
            _guest.save()
        }
    }
}
