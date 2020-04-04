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
    static let parkingSiteChanged = Notification.Name("parkingSiteChanged")
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

    static var parkingSite: ParkingSite? {
        get {
            return ParkingSite(rawValue: UserDefaults.standard.string(forKey: "selectedParkingSite") ?? "")
        }
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: "selectedParkingSite")
            NotificationCenter.default.post(Notification(name: .parkingSiteChanged))
        }
    }
}
