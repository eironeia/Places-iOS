//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

struct GetPlacesResponse: Codable {
    let places: [Place]
    let status: String

    enum CodingKeys: String, CodingKey {
        case places = "results"
        case status
    }
}
