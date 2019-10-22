//
//  UserManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 8/24/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import Foundation

class UserManager {

    static let shared = UserManager()

    private init() {}

    var appartmentName = "801 Las Co Apartments - 801 Lake Carolyn Parkway"
    var appartmentID = "95"

    var parkingCode = "LCRVP"
    var aptNumber = "3115"
    var firstName = "Anteneh"
    var lastName = "Sahledengel"

    var fullName: String {
        return firstName + " " + lastName
    }
}

