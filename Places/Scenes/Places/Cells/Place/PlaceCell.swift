//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

final class PlaceCell: UITableViewCell {
    private let viewRadius: CGFloat = 8

    private lazy var cardShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = viewRadius
        view.layer.masksToBounds = true
        return view
    }()

    private let availabilityLabel: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: Constants.FontSize.double, type: .semiBold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let cardContentContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Constants.Spacing.double
        stackView.axis = .vertical
        return stackView
    }()

    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: Constants.FontSize.double, type: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    private let ratingContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Constants.Spacing.default
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()

    private let ratingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: Constants.FontSize.small, type: .regular)
        label.textColor = .black
        return label
    }()

    private let ratingValueLabel: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: Constants.FontSize.default, type: .semiBold)
        label.textColor = .black
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        cardShadowView.layer.shadowPath = UIBezierPath(rect: cardShadowView.bounds).cgPath
        cardShadowView.layer.shadowRadius = viewRadius
        cardShadowView.layer.shadowOffset = .zero
        cardShadowView.layer.shadowOpacity = 0.2
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func setup(viewModel: PlaceCellViewModelInterface) {
        setup(availability: viewModel.availability)
        placeNameLabel.text = viewModel.name
        setup(rating: viewModel.rating)
    }
}

private extension PlaceCell {
    func setupUI() {
        setupLayout()
    }

    func setupLayout() {
        [cardShadowView, cardView].forEach {
            addSubviewWithAutolayout($0)
            $0.fillSuperview(
                withEdges: .init(
                    top: Constants.Spacing.double,
                    left: Constants.Spacing.default,
                    bottom: Constants.Spacing.double,
                    right: Constants.Spacing.default
                )
            )
        }

        [availabilityLabel, cardContentContainerView].forEach(cardView.addSubviewWithAutolayout)

        availabilityLabel.anchor(
            top: cardView.topAnchor,
            left: cardView.leftAnchor,
            right: cardView.rightAnchor,
            heightConstant: 35
        )

        cardContentContainerView.anchor(
            top: availabilityLabel.bottomAnchor,
            left: cardView.leftAnchor,
            bottom: cardView.bottomAnchor,
            right: cardView.rightAnchor,
            topConstant: Constants.Spacing.default,
            leftConstant: Constants.Spacing.double,
            bottomConstant: Constants.Spacing.default,
            rightConstant: Constants.Spacing.double
        )

        [placeNameLabel, ratingContainerView].forEach(cardContentContainerView.addArrangedSubview)
        [ratingTitleLabel, ratingValueLabel].forEach(ratingContainerView.addArrangedSubview)
    }

    func setup(availability: Place.Availability) {
        availabilityLabel.text = availability.rawValue
        switch availability {
        case .open: availabilityLabel.backgroundColor = .customGreen
        case .closed: availabilityLabel.backgroundColor = .customRed
        case .unknown: availabilityLabel.backgroundColor = .customBlue
        }
    }

    func setup(rating: Double?) {
        ratingTitleLabel.text = "Ratings"
        if let rating = rating {
            ratingValueLabel.text = "\(rating) ⭐️"
        } else {
            ratingValueLabel.text = "-"
        }
    }
}
