//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure

    var localizedDescription: String {
        switch self {
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        case .invalidURL: return "Invalid url"
        }
    }
}
