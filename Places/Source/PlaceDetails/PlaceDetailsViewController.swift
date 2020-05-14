//  Created by Alex Cuello Ortiz on 14/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit
import RxSwift
import RxCocoa

protocol PlaceDetailsViewModelInterface {

}

struct PlaceDetailsViewModel: PlaceDetailsViewModelInterface {
    enum SectionType {
        case header(HeaderCellViewModelInterface)
        case details([DetailsCellViewModel])
    }
}

class PlaceDetailsViewController: UIViewController {

    private let viewModel: PlaceDetailsViewModelInterface
    private var dataSource: [PlaceDetailsViewModel.SectionType] = [
        .header(HeaderCellViewModel()),
        .details([DetailsCellViewModel(detailsTitle: "Rating", details: "4,4")])
    ]
    private lazy var disposeBag = DisposeBag()

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
        return tableView
    }()

    init(viewModel: PlaceDetailsViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
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

private extension PlaceDetailsViewController {
    func setup() {
        setupLayout()
    }

    func setupLayout() {
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
}
