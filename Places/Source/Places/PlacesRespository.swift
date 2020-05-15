//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
import RxSwift

protocol PlacesRepositoryInterface {
    func getPlaces() -> Single<[Place]>
}

struct PlacesRepository: PlacesRepositoryInterface {
    func getPlaces() -> Single<[Place]> {
        .just(getPlacesFromMock().places)
    }
}

private extension PlacesRepository {
    func getPlacesFromMock() -> GetPlacesResponse {
        let bundle = Bundle.mockAPI
        let file = "getPlacesResponse"
        let fileExtension = "json"
        guard let filePath = bundle.url(forResource: file, withExtension: fileExtension) else {
            fatalError("Cannot find the resource \(file).\(fileExtension) at bundle \(bundle.bundlePath)" )
        }

        do {
            let data = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            let getPlacesResponse = try decoder.decode(GetPlacesResponse.self, from: data)
            return getPlacesResponse
        } catch {
            print(error)
            fatalError()
        }
    }
}

extension Bundle {
    public class var mockAPI: Bundle {
        guard let bundlePath = Bundle.main.path(forResource: "MockAPI", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath) else {
                fatalError()
        }
        return bundle
    }
}
