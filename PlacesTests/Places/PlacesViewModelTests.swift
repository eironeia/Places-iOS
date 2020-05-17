//  Created by Alex Cuello Ortiz on 17/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import XCTest
import RxSwift
@testable import Places

struct MockPlacesRepository: PlacesRepositoryInterface {
    func getPlaces(with location: Location) -> Single<GetPlacesResponse> {
        return .just(GetPlacesResponse(places: [], status: .success))
    }
}

struct MockPlacesCoordinator: PlacesCoordinatorInterface {
    var toPlacesCalled: VoidClosure?
    var toPlacesDetailsCalled: InputClosure<Place>?

    func toPlaces() {

    }

    func toPlaceDetails(place: Place) {

    }


}

class PlacesViewModelTests: XCTestCase {

    private var scheduler: TestScheduler

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

private extension PlacesViewModelTests {
    func makeSUT() -> PlacesViewModel {
        PlacesViewModel(repository: MockPlacesRepository(),
                        router: MockPlacesCoordinator())
    }
}
