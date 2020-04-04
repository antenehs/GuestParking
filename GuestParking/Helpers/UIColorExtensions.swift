//
//  UIColorExtensions.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 4/3/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init?(hexString hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        guard cString.count == 6 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIColor {

    static let appTintColor = UIColor(hexString: "007AFF")!
    static let primaryBackgroundColor = UIColor(hexString: "1A1F24")!
    static let secondaryBackgroundColor = UIColor(hexString: "282D36")!
}
