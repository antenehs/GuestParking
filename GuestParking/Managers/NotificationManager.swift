//
//  NotificationManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 1/8/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject {

    static let shared = NotificationManager()

    static let notificationCenter = UNUserNotificationCenter.current()
    static let options: UNAuthorizationOptions = [.alert, .sound, .badge]

    // MARK: Authorization

    private override init() {
        super.init()

        NotificationManager.notificationCenter.delegate = self
        observeRemindersChange()
    }

    static func isNotificationsEnabled(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized: completion(true)
            default: completion(false)
            }
        }
    }

    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: options) { (granted, _) in
            completion(granted)
        }
    }

    static func executeWhenAuthorized(block: @escaping () -> Void) {

        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral: block()
            case .notDetermined:
                self.requestAuthorization { (granted) in
                    guard granted else { return }

                    block()
                }
            case .denied:
                return
            }
        }
    }

    // MARK: Scheduling

    static func scheduleNotification(_ request: UNNotificationRequest) {
        executeWhenAuthorized {
            notificationCenter.add(request) { (error) in
                print("Notification schedules with error: \(String(describing: error))")
            }
        }
    }

    static func removeNotificationWithId(_ id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }

    static func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

extension NotificationManager {

    func observeRemindersChange() {
        NotificationCenter.default.addObserver(forName: .remindSettingValueChanged,
                                               object: nil,
                                               queue: .main) { _ in
                                                self.reminderSettingsChanged()
        }
    }

    func reminderSettingsChanged() {
        if SettingsManager.remindExpiredPassed {
            // add notifications for all passes
            Guest.allGuests().filter ({ $0.activePassExpiryDate != nil }).forEach {
                NotificationManager.scheduleNotification(for: $0)
            }
        } else {
            // Remove all notificaitons
            NotificationManager.removeAllNotifications()
        }
    }

    static func removeNotification(for guest: Guest) {
        NotificationManager.removeNotificationWithId(guest.notificationIdentifier)
    }

    static func scheduleNotification(for guest: Guest) {
        guard SettingsManager.remindExpiredPassed,
              let notificationRequest = guest.notificationRequest() else { return }

        NotificationManager.scheduleNotification(notificationRequest)
    }
}

fileprivate extension Guest {

    var notificationIdentifier: String {
        return vehiclePlateNumber
    }

    func notificationRequest() -> UNNotificationRequest? {
        guard let date = activePassExpiryDate,
            date.timeIntervalSinceNow > 0 else { return nil }

        let content = UNMutableNotificationContent()

        content.title = "Guest parking pass expired."
        content.body = "Guess parking pass for vehicle plate number \(vehiclePlateNumber) has expired."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)

        return UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
    }
}

