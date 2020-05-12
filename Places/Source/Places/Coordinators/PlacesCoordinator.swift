//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

struct PlacesCoordinator: PlacesCoordinatorInterface {
    private weak var presenter: UINavigationController?
    private let viewControllerFactory: PlacesViewControllerFactoryInterface

    init(
        presenter: UINavigationController?,
        viewControllerFactory: PlacesViewControllerFactoryInterface
    ) {
        self.presenter = presenter
        self.viewControllerFactory = viewControllerFactory
    }

    func toPlaces() {
        let viewController = viewControllerFactory.makePlacesViewController()
        presenter?.pushViewController(viewController, animated: true)
    }
}
