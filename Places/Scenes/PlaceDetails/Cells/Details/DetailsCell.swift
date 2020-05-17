//  Created by Alex Cuello Ortiz on 14/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

final class DetailsCell: UITableViewCell {
    private let container: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Constants.Spacing.default
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()

    private let detailsTitle: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: Constants.FontSize.default, type: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    private let details: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: Constants.FontSize.double, type: .semiBold)
        label.textColor = .black
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

    func setup(viewModel: DetailsCellViewModelInterface) {
        detailsTitle.text = viewModel.detailsTitle
        details.text = viewModel.details
    }
}

private extension DetailsCell {
    func setupUI() {
        setupLayout()
    }

    func setupLayout() {
        addSubviewWithAutolayout(container)
        container.fillSuperview(
            withEdges: .init(
                top: Constants.Spacing.default,
                left: Constants.Spacing.double,
                bottom: Constants.Spacing.default,
                right: Constants.Spacing.default
            )
        )
        [detailsTitle, details].forEach(container.addArrangedSubview)
    }
}
