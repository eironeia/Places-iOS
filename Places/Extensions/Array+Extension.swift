//  Created by Alex Cuello Ortiz on 17/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

extension Array where Element: Place {
    func sortedBy(sortingCriteria: PlacesViewModel.SortingCriteria) -> [Place] {
        switch sortingCriteria {
        case .rating:
            return sortPlacesByRating(places: self)
        case .availability:
            return sortPlacesByAvailability(places: self)
        }
    }

    private func sortPlacesByRating(places: [Place]) -> [Place] {
        places.sorted { (place1, place2) -> Bool in
            switch (place1.rating, place2.rating) {
            case (nil, nil): return true
            case(nil, _): return false
            case(_, nil): return true
            case let (rating1, rating2):
                guard let r1 = rating1, let r2 = rating2 else {
                    assertionFailure("This should never be triggered.")
                    return false
                }
                return r1 > r2
            }
        }
    }

    func sortPlacesByAvailability(places: [Place]) -> [Place] {
        places.sorted { (place1, place2) -> Bool in
            switch (place1.openingHours?.isOpen, place2.openingHours?.isOpen) {
            case (nil, nil): return true
            case(nil, _): return false
            case(_, nil): return true
            case let (isOpen1, _):
                return isOpen1 ?? false
            }
        }
    }

    func mapToPlacesState() -> PlacesViewModel.State {
        .places(map(PlaceCellViewModel.init))
    }
}
