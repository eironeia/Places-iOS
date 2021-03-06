//  Created by Alex Cuello Ortiz on 14/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

final class HeaderCell: UITableViewCell {
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: Constants.FontSize.big, type: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func setup(with viewModel: HeaderCellViewModelInterface?) -> Self {
        guard let viewModel = viewModel else { return self }
        headerLabel.text = viewModel.title
        return self
    }
}

private extension HeaderCell {
    func setupUI() {
        setupLayout()
    }

    func setupLayout() {
        addSubviewWithAutolayout(headerLabel)
        headerLabel.fillSuperview(
            withEdges: .init(
                top: Constants.Spacing.double,
                left: Constants.Spacing.default,
                bottom: Constants.Spacing.double,
                right: Constants.Spacing.default
            )
        )
    }
}
