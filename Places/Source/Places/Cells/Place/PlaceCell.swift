//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

final class PlaceCell: UITableViewCell {

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        //Replace for shadow
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    private let openNow: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .black
        label.text = "Closed"
        label.backgroundColor = .green
        label.textAlignment = .center
        return label
    }()

    private let cardContentContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Spacing.double
        stackView.axis = .vertical
        return stackView
    }()

    private let placeName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .black
        label.text = "Minagua"
        return label
    }()

    private let ratingContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Spacing.default
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()

    private let ratingTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        label.text = "Rating"
        return label
    }()

    private let ratingValue: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.text = "4,8"
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

    func setup(viewModel: PlaceCellViewModelInterface) {
        self.backgroundColor = .red
    }
}

private extension PlaceCell {
    func setupUI() {
        setupLayout()
    }

    func setupLayout() {
        addSubviewWithAutolayout(cardView)
        cardView.fillSuperview(
            withEdges: .init(
                top: Spacing.default,
                left: Spacing.default,
                bottom: Spacing.default,
                right: Spacing.default
            )
        )

        [openNow, cardContentContainer].forEach(cardView.addSubviewWithAutolayout)

        openNow.anchor(
            top: cardView.topAnchor,
            left: cardView.leftAnchor,
            bottom: cardView.bottomAnchor
        )

        cardContentContainer.anchor(
            top: cardView.topAnchor,
            left: openNow.rightAnchor,
            bottom: cardView.bottomAnchor,
            right: cardView.rightAnchor,
            topConstant: Spacing.default,
            leftConstant: Spacing.double,
            bottomConstant: Spacing.default,
            rightConstant: Spacing.default
        )

        openNow.anchor(widthConstant: 20)
        [placeName,ratingContainer].forEach(cardContentContainer.addArrangedSubview)
        [ratingTitle, ratingValue].forEach(ratingContainer.addArrangedSubview)
    }
}
