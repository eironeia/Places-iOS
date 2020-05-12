//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

protocol PlacesViewControllerFactoryInterface  {
    func makePlacesViewController() -> UIViewController
}

protocol PlacesCoordinatorInterface {
    func toPlaces()
}
