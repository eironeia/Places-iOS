//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

final class PlacesViewController: UIViewController {
    deinit {
        debugPrint("\(PlacesViewController.self) deinit called")
    }

    private let locationAuthorizationHandler: PlacesLocationAuthorizationHandlerInterface

    private let alertFactory: PlacesAlertFactoryInterface
    private lazy var disposeBag = DisposeBag()

    init(locationAuthorizationHandler: PlacesLocationAuthorizationHandlerInterface,
         alertFactory: PlacesAlertFactoryInterface) {
        self.locationAuthorizationHandler = locationAuthorizationHandler
        self.alertFactory = alertFactory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .green
        handleLocationAuthorization()
    }
}

//MARK: - Private methods
private extension PlacesViewController {
    //MARK: Location handling
    func handleLocationAuthorization() {
        locationAuthorizationHandler.checkLocationServices()
        locationAuthorizationHandler
            .locationStatusSubject
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] locationStatus in
                self?.handleLocationStatus(status: locationStatus)
            })
            .disposed(by: disposeBag)
    }

    func handleLocationStatus(status: PlacesLocationAuthorizationHandler.LocationStatus) {
        switch status {
        case .notDetermined:
            print("Not determined")
        case .restricted:
            handleRestrictedLocationAlert()
        case .denied:
            handleDeniedLocationStatus()
        case .authorized:
            print("Authorized")
        }
    }

    func handleRestrictedLocationAlert() {
        let action: InputClosure<UIAlertAction> = { _ in
            print("Ok pressed -> dismissed")
        }
        let alert = alertFactory.makeRestrictedAlert(action: action)
        present(alert, animated: true, completion: nil)
    }

    func handleDeniedLocationStatus() {
        let okAction: InputClosure<UIAlertAction> = { _ in
            print("Ok pressed -> dismissed")
        }

        let goSettingsAction: InputClosure<UIAlertAction> = { [weak self] _ in
            self?.goToNativeSettingsPage()
        }
        let alert = alertFactory.makeDeniedAlert(okAction: okAction, goSettingsAction: goSettingsAction)
        present(alert, animated: true, completion: nil)
    }

    @objc
    func goToNativeSettingsPage() {
        guard let url = URL(string:UIApplication.openSettingsURLString) else { return assertionFailure("URL can not be found") }
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
