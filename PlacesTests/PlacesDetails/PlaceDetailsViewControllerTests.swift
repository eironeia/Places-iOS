//  Created by Alex Cuello Ortiz on 18/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import SnapshotTesting
import XCTest
@testable import Places

class PlaceDetailsViewControllerTests: XCTestCase {
  func test_givenPlacesDetailsViewController_whenDisplayPlace_thenSnapshot() {
    let factory = PlacesViewControllerFactory()
    let place = MockPlacesRepository(response: .success).getPlacesFromMock(with: .success).places.first!
    let vc = factory.makePlaceDetailsViewController(place: place)

    assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
  }
}
