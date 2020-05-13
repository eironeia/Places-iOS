//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

final class PlacesLocationAuthorizationHandler: NSObject, CLLocationManagerDelegate, PlacesLocationAuthorizationHandlerInterface {
    enum LocationStatus {
        case notDetermined
        case restricted
        case denied
        case authorized
    }

    //MARK: PlacesLocationAuthorizationHandlerInterface
    let locationStatusSubject = PublishSubject<LocationStatus>()
    var lastLocation: CLLocation?

    //MARK: Stored properties
    private let locationManager = CLLocationManager()

    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus()
    }

    //MARK: PlacesLocationAuthorizationHandlerInterface
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            handleLocationAuthorizationStatus()
        } else {
            //TODO: To be defined
            assertionFailure("Not defined")
        }
    }
}

//MARK: - Private methods
private extension PlacesLocationAuthorizationHandler {
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func handleLocationAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationStatusSubject.onNext(.notDetermined)
        case .restricted:
            locationStatusSubject.onNext(.restricted)
        case .denied:
            locationStatusSubject.onNext(.denied)
        case .authorizedWhenInUse, .authorizedAlways:
            locationStatusSubject.onNext(.authorized)
        default: //Otherwise, it triggers a warning.
            assertionFailure("New state not handled, refer to documentation")
        }
    }
}
