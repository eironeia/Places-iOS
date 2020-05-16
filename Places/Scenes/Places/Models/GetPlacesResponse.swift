//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

struct GetPlacesResponse: Codable {
    enum StatusCode: String, Codable {
        case success = "OK"
        case noResults = "ZERO_RESULTS"
        case overQuota = "OVER_QUERY_LIMIT"
        case requestDenied = "REQUEST_DENIED"
        case invalidRequest = "INVALID_REQUEST"
        case unknown = "UNKNOWN_ERROR"

        var localizedDescription: String {
            switch self {
            case .success: return "Success status."
            case .noResults: return "Success but no results."
            case .overQuota: return "You are over your quota."
            case .requestDenied: return "Invalid API key."
            case .invalidRequest: return "Probably, parameter is missing."
            case .unknown: return "Server-side error"
            }
        }
    }

    let places: [Place]
    let status: StatusCode

    enum CodingKeys: String, CodingKey {
        case places = "results"
        case status
    }
}
