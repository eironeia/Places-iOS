//  Created by Alex Cuello Ortiz on 14/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit
import RxSwift
import RxCocoa

class PlaceDetailsViewController: UIViewController {
    deinit {
        debugPrint("\(PlaceDetailsViewController.self) deinit called")
    }

    private let viewModel: PlaceDetailsViewModelInterface
    private let eventSubject = PublishSubject<PlaceDetailsViewModel.Event>()
    private lazy var disposeBag = DisposeBag()
    private var dataSource: [PlaceDetailsViewModel.SectionType] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        tableView.register(HeaderCell.self, forCellReuseIdentifier: HeaderCell.identifier)
        tableView.register(DetailsCell.self, forCellReuseIdentifier: DetailsCell.identifier)
        tableView.allowsSelection = false
        return tableView
    }()

    init(viewModel: PlaceDetailsViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        eventSubject.onNext(.fetchPlaceDetails)
    }
}

extension PlaceDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = dataSource[safe: section] else { assertionFailure("Index out of bounds."); return 0 }
        switch sectionType {
        case .header: return 1
        case let .details(viewModels): return viewModels.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = dataSource[safe: indexPath.section] else {
            return nonFatalError(message: "Index out of bounds.")
        }
        switch sectionType {
        case let .header(viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HeaderCell.identifier) as? HeaderCell else {
                return nonFatalError(message: "Cell has not been registered.")
            }
            cell.setup(viewModel: viewModel)
            return cell
        case let .details(viewModels):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailsCell.identifier) as? DetailsCell else {
                return nonFatalError(message: "Cell has not been registered.")
            }
            guard let viewModel = viewModels[safe: indexPath.row]  else {
                return nonFatalError(message: "Index out of bounds.")
            }
            cell.setup(viewModel: viewModel)
            return cell
        }
    }
}

//MARK: - Private methods
private extension PlaceDetailsViewController {
    //MARK: Setup
    func setup() {
        setupUI()
        setupLayout()
        bindEvents()
    }

    func setupUI() {
        view.backgroundColor = .white
        title = "Details"
    }

    func setupLayout() {
        view.addSubview(tableView)
        tableView.fillSuperview()
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
    
    func handle(state: PlaceDetailsViewModel.State) {
        switch state {
        case let .sections(dataSource):
            self.dataSource = dataSource
        }
    }
}
