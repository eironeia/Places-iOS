//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import CoreLocation
import RxCocoa
import RxSwift
import UIKit

// MARK: - Alert Factory

protocol PlacesAlertFactoryInterface {
    func makeRestrictedAlert(action: ((UIAlertAction) -> Void)?) -> UIAlertController
    func makeDeniedAlert(action: ((UIAlertAction) -> Void)?) -> UIAlertController
    func makeErrorAlert(title: String, message: String) -> UIAlertController
    func makeSortingCriteriaAlert(
        rating: ((UIAlertAction) -> Void)?,
        availability: ((UIAlertAction) -> Void)?
    ) -> UIAlertController
}

// MARK: - Location Authorization

protocol PlacesLocationAuthorizationHandlerInterface {
    var locationStatusSubject: PublishSubject<PlacesLocationAuthorizationHandler.LocationStatus> { get }
    var lastLocation: Location? { get }
    func checkLocationServices()
}

// MARK: - ViewController Factory

protocol PlacesViewControllerFactoryInterface {
    func makePlacesViewController(router: PlacesCoordinatorInterface) -> UIViewController
    func makePlaceDetailsViewController(place: Place) -> UIViewController
}

// MARK: - Coordinator Factory

protocol PlacesCoordinatorInterface {
    func toPlaces()
    func toPlaceDetails(place: Place)
}

// MARK: - PlacesViewModel

protocol PlacesViewModelInterface {
    func transform(event: Observable<PlacesViewModel.Event>) -> Observable<PlacesViewModel.State>
}

// MARK: - Repository

protocol PlacesRepositoryInterface {
    func getPlaces(with location: Location) -> Single<GetPlacesResponse>
}

// MARK: - GetPlacesEndpoint

protocol GetPlacesEndpointInterface: EndpointInterface {}

extension GetPlacesEndpointInterface {
    var base: String {
        return "https://maps.googleapis.com"
    }

    var path: String {
        return "/maps/api/place/nearbysearch/json"
    }
}
