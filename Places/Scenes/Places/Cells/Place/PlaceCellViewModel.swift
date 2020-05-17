//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

protocol PlaceCellViewModelInterface {
    var name: String { get }
    var rating: Double? { get }
    var availability: Place.Availability { get }
}

struct PlaceCellViewModel: PlaceCellViewModelInterface {
    private let place: Place

    var name: String {
        place.name
    }

    var rating: Double? {
        place.rating
    }

    var availability: Place.Availability {
        place.availability
    }

    init(place: Place) {
        self.place = place
    }
}
