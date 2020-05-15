//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

protocol PlaceCellViewModelInterface {
    var name: String { get }
    var rating: Double? { get }
    var availability: PlaceCellViewModel.Availability { get }
}

struct PlaceCellViewModel: PlaceCellViewModelInterface {
    enum Availability: String {
        case open = "Open"
        case closed = "Closed"
        case unknown = "Unknown"
    }

    private let place: Place

    var name: String {
        place.name
    }

    var rating: Double? {
        place.rating
    }

    var availability: Availability {
        guard let isOpen = place.openingHours?.isOpen else { return .unknown }
        return isOpen ? .open : .closed
    }

    init(place: Place) {
        self.place = place
    }
}
