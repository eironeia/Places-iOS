//  Created by Alex Cuello Ortiz on 18/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
@testable import Places

struct MockPlacesCoordinator: PlacesCoordinatorInterface {
    let toPlacesCalled: VoidClosure?
    let toPlacesDetailsCalled: VoidClosure?

    init(toPlacesCalled: VoidClosure? = nil, toPlacesDetailsCalled: VoidClosure? = nil) {
        self.toPlacesCalled = toPlacesCalled
        self.toPlacesDetailsCalled = toPlacesDetailsCalled
    }

    func toPlaces() {
        toPlacesCalled?()
    }

    func toPlaceDetails(place: Place) {
        toPlacesDetailsCalled?()
    }
}
