//  Created by Alex Cuello Ortiz on 14/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

final class HeaderCell: UITableViewCell {

    private let header: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: FontSize.big, type: .bold)
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

    func setup(viewModel: HeaderCellViewModelInterface) {
        header.text = viewModel.title
    }
}

private extension HeaderCell {
    func setupUI() {
        setupLayout()
    }

    func setupLayout() {
        addSubviewWithAutolayout(header)
        header.fillSuperview(
            withEdges: .init(
                top: Spacing.double,
                left: Spacing.default,
                bottom: Spacing.double,
                right: Spacing.default
            )
        )
    }
}
