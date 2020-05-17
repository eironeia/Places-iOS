//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import PKHUD

final class PlacesViewController: UIViewController {
    deinit {
        debugPrint("\(PlacesViewController.self) deinit called")
    }

    private let locationAuthorizationHandler: PlacesLocationAuthorizationHandlerInterface
    private let alertFactory: PlacesAlertFactoryInterface
    private let viewModel: PlacesViewModelInterface

    private let eventSubject = PublishSubject<PlacesViewModel.Event>()
    private lazy var disposeBag = DisposeBag()

    private var dataSource: [PlaceCellViewModelInterface] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        tableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.identifier)
        tableView.refreshControl = refreshControl
        return tableView
    }()

    private let placeholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.isHidden = true
        return view
    }()

    private lazy var floatingScrollToTopButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Scroll to top", for: .normal)
        button.setTitleColor(.customOrange, for: .normal)
        button.layer.borderColor = UIColor.customOrange.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.titleEdgeInsets = .init(
            top: Constants.Spacing.default,
            left: Constants.Spacing.default,
            bottom: Constants.Spacing.default,
            right: Constants.Spacing.default
        )
        button.titleLabel?.font = .circleRoundedFont(size: Constants.FontSize.double, type: .semiBold)
        button.addTarget(self, action: #selector(self.scrollToTop), for: .touchUpInside)
        return button
    }()

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
        setup()
    }
}

//TableView Delegate
extension PlacesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        eventSubject.onNext(.placeTapped(indexPath))
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleShowFloatingButton()
    }
}

//MARK - TableView DataSource
extension PlacesViewController: UITableViewDataSource {
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
}

//MARK: - Private methods
private extension PlacesViewController {
    //MARK: Setup
    func setup() {
        setupUI()
        setupLayout()
        bindEvents()
    }

    func setupUI() {
        view.backgroundColor = .white
        title = "Places"
    }

    func setupLayout() {
        [placeholderView, tableView, floatingScrollToTopButton].forEach(view.addSubview)
        [placeholderView, tableView].forEach({ $0.fillSuperview() })
        floatingScrollToTopButton.anchorCenterXToSuperview()
        floatingScrollToTopButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            topConstant: Constants.Spacing.default,
            widthConstant: 120
        )
    }

    func handleShowFloatingButton() {
        if let firstVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.first {
            floatingScrollToTopButton.isHidden = firstVisibleIndexPath.row < 5
        } else {
            floatingScrollToTopButton.isHidden = true
        }
    }

    //MARK: Location handling
    func handle(locationStatus: PlacesLocationAuthorizationHandler.LocationStatus) {
        navigationItem.rightBarButtonItems = nil
        switch locationStatus {
        case .notDetermined:
            handleNotAuthorizedUI(text: "Waiting for location approval ✅")
        case .restricted:
            handleRestrictedLocationAlert()
        case .denied:
            handleDeniedLocationStatus()
        case let .authorized(location):
            handleAuthorizedStatusUI()
            eventSubject.onNext(.fetchPlaces(location))
        }
    }

    func handleRestrictedLocationAlert() {
        let alert = alertFactory.makeRestrictedAlert(
            action: ({ [weak self] _ in
                self?.handleNotAuthorizedUI(text: "Location is restricted 😢\nPlease change it on Settings ⚙️")
            })
        )
        present(alert, animated: true, completion: nil)
    }

    func handleDeniedLocationStatus() {
        let alert = alertFactory.makeDeniedAlert(
            action: ({ [weak self] _ in
                self?.handleNotAuthorizedUI(text: "Location denied 🙅🏻‍♂️\nPlease change it on Settings ⚙️")
                self?.goToNativeSettingsPage()
            })
        )
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

        locationAuthorizationHandler
            .locationStatusSubject
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] locationStatus in
                self?.handle(locationStatus: locationStatus)
            })
            .disposed(by: disposeBag)

        locationAuthorizationHandler.checkLocationServices()
    }

    func handle(state: PlacesViewModel.State) {
        switch state {
        case let .places(viewModels):
            dataSource = viewModels
            if dataSource.isEmpty {
                show(placeHolder: false)
                placeholderView.setup(text: "There are no nearby places 😞")
            }
        case let .isLoading(isLoading):
            isLoading ? HUD.show(.progress) : HUD.hide()
        case let .error(error):
            let alert = alertFactory.makeErrorAlert(title: error.information.title, message: error.information.message)
            present(alert, animated: true, completion: nil)
        case .idle: break
        }
    }

    @objc
    func sortButtonTapped() {
        let alert = alertFactory.makeSortingCriteriaAlert(
            rating: ({ [weak self] _ in
                self?.eventSubject.onNext(.changeSortCriteria(.rating))
            }),
            availability: ({ [weak self] _ in
                self?.eventSubject.onNext(.changeSortCriteria(.availability))
            })
        )

        present(alert, animated: true, completion: nil)
    }

    func show(placeHolder showPlaceHolder: Bool = false, tableView showTableView: Bool = false, floatingScrollToTop showFloatingScrollToTop: Bool = false) {
        placeholderView.isHidden = !showPlaceHolder
        tableView.isHidden = !showTableView
        floatingScrollToTopButton.isHidden = !showFloatingScrollToTop
    }

    func handleNotAuthorizedUI(text: String) {
        show(placeHolder: true)
        placeholderView.setup(text: text)
    }

    func handleAuthorizedStatusUI() {
        show(tableView: true)
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(sortButtonTapped))
        let retryBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(retryRequest))
        navigationItem.rightBarButtonItems = [addBarButtonItem, retryBarButtonItem]
    }

    @objc
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard tableView.numberOfRows(inSection: 0) > 0 else { return }
        floatingScrollToTopButton.isHidden = true
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    @objc
    func pullToRefresh() {
        refreshControl.endRefreshing()
        sendFetchPlacesEvent()
    }

    @objc
    func retryRequest() {
        sendFetchPlacesEvent()
    }

    func sendFetchPlacesEvent() {
        guard let location = locationAuthorizationHandler.lastLocation else { debugPrint("Empty last location"); return }
        eventSubject.onNext(.fetchPlaces(location))
    }
}

//Monitoring example:
func nonFatalError(message: String) -> UITableViewCell {
    assertionFailure(message)
    return UITableViewCell()
}
