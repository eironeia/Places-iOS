//  Created by Alex Cuello Ortiz on 18/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

final class MockTableViewController: UITableViewController {

    init(cells: [UITableViewCell]) {
        super.init(nibName: nil, bundle: nil)
        self.cells = cells
        tableView.separatorStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var cells: [UITableViewCell] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells.count
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cells[indexPath.row]
    }

    var firstRowCell: UITableViewCell? {
        tableView.cellForRow(at: .init(row: 0, section: 0))
    }
}
