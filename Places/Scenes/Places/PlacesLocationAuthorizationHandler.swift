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
        case authorized(Location)
    }

    //MARK: PlacesLocationAuthorizationHandlerInterface
    let locationStatusSubject = PublishSubject<LocationStatus>()
    var lastLocation: Location?

    //MARK: Stored properties
    private let locationManager = CLLocationManager()
    private var isUpdatingLocationFirstTime: Bool = true

    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        sendLocationEvent(from: locations.last?.coordinate)
    }

    //MARK: PlacesLocationAuthorizationHandlerInterface
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            handleLocationAuthorizationStatus()
        } else {
            locationStatusSubject.onNext(.restricted)
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
        isUpdatingLocationFirstTime = true
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationStatusSubject.onNext(.notDetermined)
        case .restricted:
            locationStatusSubject.onNext(.restricted)
        case .denied:
            locationStatusSubject.onNext(.denied)
        case .authorizedWhenInUse, .authorizedAlways:
            sendLocationEvent(from: locationManager.location?.coordinate)
        default: //Otherwise, it triggers a warning.
            assertionFailure("New state not handled, refer to documentation")
        }
    }

    func sendLocationEvent(from coordinate: CLLocationCoordinate2D?) {
        guard let coordinate = coordinate else {
            debugPrint("Error: Device location is nil, please make sure location is activated, or if using simulator you are set a location.")
            return
        }
        let location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
        lastLocation = location
        if isUpdatingLocationFirstTime {
            isUpdatingLocationFirstTime = false
            locationStatusSubject.onNext(.authorized(location))
        }
    }
}
