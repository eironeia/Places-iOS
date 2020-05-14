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

    private let availability: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: FontSize.double, type: .semiBold)
        label.textColor = .white
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
        label.font = .circleRoundedFont(size: FontSize.double, type: .bold)
        label.textColor = .black
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
        label.font = .circleRoundedFont(size: FontSize.small, type: .regular)
        label.textColor = .black
        return label
    }()

    private let ratingValue: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: FontSize.default, type: .semiBold)
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
        placeName.text = viewModel.name
        setup(rating: viewModel.rating)
    }
}

private extension PlaceCell {
    func setupUI() {
        setupLayout()
    }

    func setupLayout() {
        [cardShadowView, cardView].forEach({
            addSubviewWithAutolayout($0)
            $0.fillSuperview(
                withEdges: .init(
                    top: Spacing.double,
                    left: Spacing.default,
                    bottom: Spacing.double,
                    right: Spacing.default
                )
            )
        })

        [availability, cardContentContainer].forEach(cardView.addSubviewWithAutolayout)

        availability.anchor(
            top: cardView.topAnchor,
            left: cardView.leftAnchor,
            right: cardView.rightAnchor,
            heightConstant: 35
        )

        cardContentContainer.anchor(
            top: availability.bottomAnchor,
            left: cardView.leftAnchor,
            bottom: cardView.bottomAnchor,
            right: cardView.rightAnchor,
            topConstant: Spacing.default,
            leftConstant: Spacing.default,
            bottomConstant: Spacing.default,
            rightConstant: Spacing.default
        )

        [placeName,ratingContainer].forEach(cardContentContainer.addArrangedSubview)
        [ratingTitle, ratingValue].forEach(ratingContainer.addArrangedSubview)
    }

    func setup(availability: PlaceCellViewModel.Availability) {
        self.availability.text = availability.rawValue
        switch availability {
        case .open: self.availability.backgroundColor = .customGreen
        case .closed: self.availability.backgroundColor = .customRed
        case .unknown: self.availability.backgroundColor = .customBlue
        }
    }

    func setup(rating: Double?) {
        ratingTitle.text = "Ratings"
        if let rating = rating {
            ratingValue.text = "\(rating)"
        } else {
            ratingValue.text = "-"
        }
    }
}
