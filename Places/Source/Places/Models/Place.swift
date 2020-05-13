//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

struct Place: Codable {
    let name: String
    let openNow: Bool
    let rating: Double

    enum CodingKeys: String, CodingKey {
        case name
        case openNow = "open_now"
        case rating
    }
}
