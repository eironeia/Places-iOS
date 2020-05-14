//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

// MARK: - GetPlacesResponse
struct GetPlacesResponse: Codable {
    let places: [Place]
    let status: String

    enum CodingKeys: String, CodingKey {
        case places = "results"
        case status
    }
}

// MARK: - Result
struct Place: Codable {
    let geometry: Geometry
    let name: String
    let openingHours: OpeningHours?
    let plusCode: PlusCode?
    let priceLevel: Int?
    let rating: Double?
    let userRatingsTotal: Int?

    enum CodingKeys: String, CodingKey {
        case geometry
        case name
        case openingHours = "opening_hours"
        case plusCode = "plus_code"
        case priceLevel = "price_level"
        case rating
        case userRatingsTotal = "user_ratings_total"
    }
}

// MARK: - Geometry
struct Geometry: Codable {
    let location: Location
}

// MARK: - Location
struct Location: Codable {
    let lat: Double
    let lng: Double
}

// MARK: - OpeningHours
struct OpeningHours: Codable {
    let isOpen: Bool

    enum CodingKeys: String, CodingKey {
        case isOpen = "open_now"
    }
}

// MARK: - PlusCode
struct PlusCode: Codable {
    let compoundCode: String
    let globalCode: String

    enum CodingKeys: String, CodingKey {
        case compoundCode = "compound_code"
        case globalCode = "global_code"
    }
}
