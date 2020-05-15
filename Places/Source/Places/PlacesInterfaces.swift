//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

//MARK: - Alert Factory
protocol PlacesAlertFactoryInterface {
    func makeRestrictedAlert(action: ((UIAlertAction) -> Void)?) -> UIAlertController
    func makeDeniedAlert(action: ((UIAlertAction) -> Void)?) -> UIAlertController
    func makeErrorAlert(error: PlacesViewModel.ErrorType) -> UIAlertController
    func makeSortingCriteriaAlert(rating: ((UIAlertAction) -> Void)?, availability: ((UIAlertAction) -> Void)?) -> UIAlertController
}

protocol PlacesLocationAuthorizationHandlerInterface {
    var locationStatusSubject: PublishSubject<PlacesLocationAuthorizationHandler.LocationStatus> { get }
//    var lastLocation: CLLocation? { get }
    func checkLocationServices()
}

//MARK: - ViewController Factory
protocol PlacesViewControllerFactoryInterface  {
    func makePlacesViewController(router: PlacesCoordinatorInterface) -> UIViewController
    func makePlaceDetailsViewController(place: Place) -> UIViewController
}

//MARK: - Coordinator Factory
protocol PlacesCoordinatorInterface {
    func toPlaces()
    func toPlaceDetails(place: Place)
}

//MARK: - PlacesViewModel
protocol PlacesViewModelInterface {
    func transform(event: Observable<PlacesViewModel.Event>) -> Observable<PlacesViewModel.State>
}
