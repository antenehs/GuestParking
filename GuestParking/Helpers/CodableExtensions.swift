//
//  CodableExtensions.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 3/30/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation

extension Encodable {
    func toDictionary() -> [AnyHashable: Any]? {
        guard let data = try? JSONEncoder().encode(self),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any] else {
                return nil
        }

        return dictionary
    }
}

extension Decodable {
    static func initFrom(dictionary: [AnyHashable: Any]) -> Self? {
        let decoder = JSONDecoder()
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return nil }

        return try? decoder.decode(Self.self, from: data)
    }
}
