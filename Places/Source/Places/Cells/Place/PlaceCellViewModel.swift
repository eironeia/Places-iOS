//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

protocol PlaceCellViewModelInterface {
    var name: String { get }
    var rating: Double { get }
    var openNow: Bool { get }
}

struct PlaceCellViewModel: PlaceCellViewModelInterface {
    let name: String
    let rating: Double
    let openNow: Bool

    init(place: Place) {
        name = place.name
        rating = place.rating
        openNow = place.openNow
    }
}
