//
//  NotificationManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 1/8/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager {

    static let notificationCenter = UNUserNotificationCenter.current()
    static let options: UNAuthorizationOptions = [.alert, .sound, .badge]

    // MARK: Authorization

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
            case .authorized, .provisional: block()
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

extension NotificationManager {

    static func removeNotification(for guest: Guest) {
        NotificationManager.removeNotificationWithId(guest.notificationIdentifier)
    }

    static func scheduleNotification(for guest: Guest) {
        // TODO: If notificaiton is enabled in settings
        
        guard let notificationRequest = guest.notificationRequest() else { return }

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

        let content = UNMutableNotificationContent() // Содержимое уведомления

        content.title = "Guest parking pass expired."
        content.body = "Guess parking pass for vehicle plate number \(vehiclePlateNumber) has expired."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)

        return UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
    }
}

