//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import CoreLocation
import RxCocoa
import RxSwift
import UIKit

final class PlacesLocationAuthorizationHandler: NSObject {
    enum LocationStatus {
        case notDetermined
        case restricted
        case denied
        case authorized(Location)
    }

    // MARK: PlacesLocationAuthorizationHandler Interface

    private let locationStatusSubject = PublishSubject<LocationStatus>()
    lazy var locationStatusObservable: Observable<LocationStatus> = locationStatusSubject.asObservable()
    private(set) var lastLocation: Location?

    // MARK: Stored properties

    private let locationManager = CLLocationManager()
    private var isUpdatingLocationFirstTime: Bool = true
}

extension PlacesLocationAuthorizationHandler: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus) {
        handleLocationAuthorizationStatusChanges()
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        sendLocationEvent(from: locations.last?.coordinate)
    }
}

extension PlacesLocationAuthorizationHandler: PlacesLocationAuthorizationHandlerInterface {
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            handleLocationAuthorizationStatusChanges()
        } else {
            locationStatusSubject.onNext(.restricted)
        }
    }
}

private extension PlacesLocationAuthorizationHandler {
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func handleLocationAuthorizationStatusChanges() {
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
        default: // Otherwise, it triggers a warning.
            assertionFailure("New state not handled, refer to documentation")
        }
    }

    func sendLocationEvent(from coordinate: CLLocationCoordinate2D?) {
        guard let coordinate = coordinate else {
            debugPrint("Location is not activated, or if using simulator you are set a location.")
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
