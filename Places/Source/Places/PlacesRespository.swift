//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
import RxSwift

protocol PlacesRepositoryInterface {
    func getPlaces() -> Single<[Place]>
}

struct PlacesRepository: PlacesRepositoryInterface {
    func getPlaces() -> Single<[Place]> {
        .just([
            Place(name: "Alex", openNow: true, rating: 4),
            Place(name: "Sam", openNow: true, rating: 1.9),
            Place(name: "Anton", openNow: false, rating: 2.3)
        ])
    }
}
