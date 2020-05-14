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

    private var finishedLoadingInitialTableCells = false
    private let locationAuthorizationHandler: PlacesLocationAuthorizationHandlerInterface
    private let alertFactory: PlacesAlertFactoryInterface
    private let viewModel: PlacesViewModelInterface
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.identifier)
        return tableView
    }()
    private lazy var disposeBag = DisposeBag()

    private let eventSubject = PublishSubject<PlacesViewModel.Event>()
    private var dataSource: [PlaceCellViewModelInterface] = [] {
        didSet {
            finishedLoadingInitialTableCells = false
            tableView.reloadData()
        }
    }

    init(
        locationAuthorizationHandler: PlacesLocationAuthorizationHandlerInterface,
        alertFactory: PlacesAlertFactoryInterface,
        viewModel: PlacesViewModelInterface
    ) {
        self.locationAuthorizationHandler = locationAuthorizationHandler
        self.alertFactory = alertFactory
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .green
        setup()
        eventSubject.onNext(.fetchPlaces)
    }
}

//MARK - TableView DataSource
extension PlacesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.identifier) as? PlaceCell else {
            return nonFatalError(message: "Cell has not been registered.")
        }
        guard let viewModel = dataSource[safe: indexPath.row] else {
            return nonFatalError(message: "Index out of bounds.")
        }
        cell.setup(viewModel: viewModel)
        return cell
    }



    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !finishedLoadingInitialTableCells else { return }
        finishedLoadingInitialTableCells = !dataSource.isEmpty
            && !finishedLoadingInitialTableCells
            && tableView.indexPathsForVisibleRows?.last?.row == indexPath.row
        cell.transform = CGAffineTransform(translationX: 0, y: 20)
        cell.alpha = 0

        UIView.animate(withDuration: 0.5, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
            cell.transform = CGAffineTransform(translationX: 0, y: 0)
            cell.alpha = 1
        }, completion: nil)
    }
}

//MARK: - Private methods
private extension PlacesViewController {
    func setup() {
        let add = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = add

        setupLayout()
        setupLocationAuthorization()
        bindEvents()
    }

    func setupLayout() {
        view.addSubview(tableView)
        tableView.fillSuperview()
    }

    //MARK: Location handling
    func setupLocationAuthorization() {
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
        let action: InputClosure<UIAlertAction> = { [weak self] _ in
            print("Ok pressed -> dismissed")
            self?.view.backgroundColor = .blue
        }
        let alert = alertFactory.makeRestrictedAlert(action: action)
        present(alert, animated: true, completion: nil)
    }

    func handleDeniedLocationStatus() {
        let okAction: InputClosure<UIAlertAction> = { [weak self] _ in
            print("Ok pressed -> dismissed")
            self?.view.backgroundColor = .red
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

    //MARK: ViewModel
    func bindEvents() {
        viewModel
            .transform(event: eventSubject)
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] state in
                self?.handle(state: state)
            })
            .disposed(by: disposeBag)
    }

    func handle(state: PlacesViewModel.State) {
        print(state)
        switch state {
        case let .places(viewModels):
            dataSource = viewModels
        case let .error(error):
            let alert = alertFactory.makeErrorAlert(error: error)
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }

    //Monitoring example:
    func nonFatalError(message: String) -> UITableViewCell {
        assertionFailure(message)
        return UITableViewCell()
    }

    @objc
    func addTapped() {
        eventSubject.onNext(.changeSortCriteria(.availability))
    }
}
