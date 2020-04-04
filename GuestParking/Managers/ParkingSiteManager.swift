//
//  ParkingSiteManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 4/2/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import UIKit

enum ParkingSite: String, Codable, CaseIterable {
    case parkingBadge = "ParkingBadge"
    case register2Park = "Register2Park"

    func pageManager() -> PageManager {
        switch self {
        case .parkingBadge:
            return ParkingBadgePageManager()
        case .register2Park:
            return Register2ParkPageManager()
        }
    }

    var logoImage: UIImage? {
        switch self {
        case .parkingBadge: return UIImage(named: "parkingbadge_logo")
        case .register2Park: return UIImage(named: "register2park_logo")
        }
    }
}
