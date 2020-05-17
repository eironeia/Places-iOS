//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
import RxSwift

struct PlacesRepository: PlacesRepositoryInterface, APIClient {
    let session: URLSession

    // This is only meant to be just in case when trying the app Places API is not working.
    // This mock should be only allocated on test section.
    private let mockRepository = MockPlacesRepository(response: .success)

    init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }

    func getPlaces(with location: Location) -> Single<GetPlacesResponse> {
//            rxRequest(with: GetPlacesEndpoint(location: location).request)
        mockRepository.getPlaces(with: location)
    }
}

struct MockPlacesRepository: PlacesRepositoryInterface {
    enum Response {
        case success
        case noResults
        case overQuota
        case requestDenied
    }

    let response: Response

    func getPlaces(with location: Location) -> Single<GetPlacesResponse> {
        switch response {
        case .success:
            return .just(getPlacesResponseFromMock(file: "getPlacesResponse"))
        case .noResults:
            return .just(getPlacesResponseFromMock(file: "getPlacesResponseZeroResults"))
        case .overQuota:
            return .just(getPlacesResponseFromMock(file: "getPlacesResponseQuotaLimit"))
        case .requestDenied:
            return .just(getPlacesResponseFromMock(file: "getPlacesResponseRequestDenied"))
        }
    }

    func getPlacesResponseFromMock(file: String) -> GetPlacesResponse {
        let bundle = Bundle.mockAPI
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
