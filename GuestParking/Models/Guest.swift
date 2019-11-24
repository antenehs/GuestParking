//
//  Guest.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 8/24/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import Foundation

struct Guest: Codable {
    var firstName: String = ""
    var lastName: String = ""
    var phoneNumber: String = ""
    var emailAddress: String = ""
    var vehicleYear: String = ""
    var vehicleMake: String = ""
    var vehicleModel: String = ""
    var vehicleColor: String = ""
    var vehiclePlateState: String = ""
    var vehiclePlateNumber: String = ""

    var activePassMessage: String?
    var activePassExpiryDate: Date?

    var activePermitDisplayString: String? {
//        if firstName == "AUDI" { return nil }
        if let date = activePassExpiryDate {
            return date.timeIntervalSinceNow > 0 ?  activePassMessage : nil
        } else {
            return activePassMessage
        }
    }

    static func == (lhs: Guest, rhs: Guest) -> Bool {
        return lhs.vehiclePlateNumber == rhs.vehiclePlateNumber
    }

    func save() {
        DiskPersistanceStore.shared.save(object: self)
    }

    func delete() {
        DiskPersistanceStore.shared.deleteObjectOf(type: Guest.self, primaryKey: primaryKey)
    }

    static func allGuests() -> [Guest] {
        return DiskPersistanceStore.shared.getAllObjectsOf(type: self)
    }
}

extension Guest: PersistenceModel {
    var primaryKey: String {
        return vehiclePlateNumber
    }
}
