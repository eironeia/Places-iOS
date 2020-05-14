//  Created by Alex Cuello Ortiz on 14/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

protocol DetailsCellViewModelInterface {
    var detailsTitle: String { get }
    var details: String { get }
}

struct DetailsCellViewModel: DetailsCellViewModelInterface {
    let detailsTitle: String
    let details: String
    init(detailsTitle: String, details: String) {
        self.detailsTitle = detailsTitle
        self.details = details
    }
}

final class DetailsCell: UITableViewCell {

    private let container: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Spacing.default
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()

    private let detailsTitle: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: FontSize.default, type: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    private let details: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: FontSize.double, type: .semiBold)
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
                top: Spacing.default,
                left: Spacing.double,
                bottom: Spacing.default,
                right: Spacing.default
            )
        )
        [detailsTitle, details].forEach(container.addArrangedSubview)
    }
}
