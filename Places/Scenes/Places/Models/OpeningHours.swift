//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

struct OpeningHours: Codable {
    let isOpen: Bool

    enum CodingKeys: String, CodingKey {
        case isOpen = "open_now"
    }
}
