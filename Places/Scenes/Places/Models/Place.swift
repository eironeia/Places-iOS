//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

struct Place: Codable {
    let name: String
    let openingHours: OpeningHours?
    let priceLevel: Int?
    let rating: Double?
    let userRatingsTotal: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case openingHours = "opening_hours"
        case priceLevel = "price_level"
        case rating
        case userRatingsTotal = "user_ratings_total"
    }
}
