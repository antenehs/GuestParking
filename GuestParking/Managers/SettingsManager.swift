//
//  SettingsManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 2/1/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let remindSettingValueChanged = Notification.Name("remindSettingValueChanged")
}

class SettingsManager {

    static var remindExpiredPassed: Bool {
        get {
            UserDefaults.standard.bool(forKey: "remindExpiredPassed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "remindExpiredPassed")
            NotificationCenter.default.post(Notification(name: .remindSettingValueChanged))
        }
    }
}
