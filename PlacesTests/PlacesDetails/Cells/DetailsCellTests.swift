//  Created by Alex Cuello Ortiz on 18/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import SnapshotTesting
import XCTest
@testable import Places

class DetailsCellTests: XCTestCase {
  func test_givenDetailsCell_whenDisplayDetails_thenSnapshot_() {

    let cell = DetailsCell()
        .setup(with: DetailsCellViewModel(detailsTitle: "Test", details: "Test"))
    let tableViewController = MockTableViewController(cells: [cell])
    assertSnapshot(matching: tableViewController, as: .image(on: .iPhoneX))
  }
}
