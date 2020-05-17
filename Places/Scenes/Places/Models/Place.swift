//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

final class Place: Codable {
    enum Availability: String {
        case open = "Open"
        case closed = "Closed"
        case unknown = "Unknown"
    }

    let name: String
    let openingHours: OpeningHours?

    let priceLevel: Int?
    let rating: Double?
    let userRatingsTotal: Int?

    var availability: Availability {
        if let isOpen = openingHours?.isOpen {
            return isOpen ? .open : .closed
        } else {
            return .unknown
        }
    }

    enum CodingKeys: String, CodingKey {
        case name
        case openingHours = "opening_hours"
        case priceLevel = "price_level"
        case rating
        case userRatingsTotal = "user_ratings_total"
    }
}
