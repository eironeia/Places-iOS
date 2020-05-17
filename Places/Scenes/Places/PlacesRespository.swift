//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
import RxSwift

struct PlacesRepository: PlacesRepositoryInterface, APIClient {
    let session: URLSession

    init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }

    func getPlaces(with location: Location) -> Single<GetPlacesResponse> {
            rxRequest(with: GetPlacesEndpoint(location: location).request)
//        getPlacesFromMock()
    }
}

private extension PlacesRepository {
    func getPlacesFromMock() -> Single<GetPlacesResponse> {
        .just(getPlacesResponseFromMock())
    }

    func getPlacesResponseFromMock() -> GetPlacesResponse {
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
            fatalError()
        }
    }

}
