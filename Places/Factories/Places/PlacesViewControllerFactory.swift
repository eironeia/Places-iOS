//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

struct PlacesViewControllerFactory: PlacesViewControllerFactoryInterface {
    func makePlacesViewController(router: PlacesCoordinatorInterface) -> UIViewController {
        PlacesViewController(
            locationAuthorizationHandler: PlacesLocationAuthorizationHandler(),
            alertFactory: PlacesAlertFactory(),
            viewModel: PlacesViewModel(repository: PlacesRepository(), router: router)
        )
    }

    func makePlaceDetailsViewController() -> UIViewController {
        PlaceDetailsViewController(viewModel: PlaceDetailsViewModel())
    }
}
