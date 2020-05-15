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
    private lazy var disposeBag = DisposeBag()

    private let eventSubject = PublishSubject<PlacesViewModel.Event>()
    private var dataSource: [PlaceCellViewModelInterface] = [] {
        didSet {
            tableView.reloadData()
        }
    }

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
            top: Spacing.default,
            left: Spacing.default,
            bottom: Spacing.default,
            right: Spacing.default
        )
        button.titleLabel?.font = .circleRoundedFont(size: FontSize.double, type: .semiBold)
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
    func setup() {
        setupUI()
        setupLayout()
        bindEvents()
        setupLocationAuthorization()
    }

    func setupUI() {
        view.backgroundColor = .white
        let add = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(sortButtonTapped))
        navigationItem.rightBarButtonItem = add
    }

    func setupLayout() {
        [placeholderView, tableView, floatingScrollToTopButton].forEach(view.addSubview)
        [placeholderView, tableView].forEach({ $0.fillSuperview() })
        floatingScrollToTopButton.anchorCenterXToSuperview()
        floatingScrollToTopButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            topConstant: Spacing.default,
            widthConstant: 120
        )
    }

    //MARK: Location handling
    func setupLocationAuthorization() {
        locationAuthorizationHandler
            .locationStatusSubject
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] locationStatus in
                self?.handleLocationStatus(status: locationStatus)
            })
            .disposed(by: disposeBag)
        locationAuthorizationHandler.checkLocationServices()
    }

    func handleLocationStatus(status: PlacesLocationAuthorizationHandler.LocationStatus) {
        switch status {
        case .notDetermined:
            showPlaceholder(text: "Waiting for location approval ✅")
        case .restricted:
            handleRestrictedLocationAlert()
        case .denied:
            handleDeniedLocationStatus()
        case .authorized:
            hidePlaceholder()
            eventSubject.onNext(.fetchPlaces)
        }
    }

    func handleRestrictedLocationAlert() {
        let alert = alertFactory.makeRestrictedAlert(
            action: ({ [weak self] _ in
                self?.showPlaceholder(text: "Location is restricted 😢\nPlease change it on Settings ⚙️")
            })
        )
        present(alert, animated: true, completion: nil)
    }

    func handleDeniedLocationStatus() {
        let alert = alertFactory.makeDeniedAlert(
            action: ({ [weak self] _ in
                self?.showPlaceholder(text: "Location denied 🙅🏻‍♂️\nPlease change it on Settings ⚙️")
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
    }

    func handle(state: PlacesViewModel.State) {
        switch state {
        case let .places(viewModels):
            dataSource = viewModels
        case let .error(error):
            let alert = alertFactory.makeErrorAlert(error: error)
            present(alert, animated: true, completion: nil)
        case let .isLoading(isLoading):
            if isLoading {
                HUD.show(.progress)
            } else {
                HUD.hide()
            }
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

    func showPlaceholder(text: String) {
        placeholderView.isHidden = false
        tableView.isHidden = true
        floatingScrollToTopButton.isHidden = true
        placeholderView.setup(text: text)
    }

    func hidePlaceholder() {
        placeholderView.isHidden = true
        tableView.isHidden = false
        floatingScrollToTopButton.isHidden = true
    }

    @objc
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard tableView.numberOfRows(inSection: 0) > 0 else { return }
        floatingScrollToTopButton.isHidden = true
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    func handleShowFloatingButton() {
        if let firstVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.first {
            floatingScrollToTopButton.isHidden = firstVisibleIndexPath.row < 5
        } else {
            floatingScrollToTopButton.isHidden = true
        }
    }
}

//Monitoring example:
func nonFatalError(message: String) -> UITableViewCell {
    assertionFailure(message)
    return UITableViewCell()
}
