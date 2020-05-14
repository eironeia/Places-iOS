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
        label.font = .systemFont(ofSize: 18)
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
        case .open: self.availability.backgroundColor = UIColor(red: 0.01, green: 0.75, blue: 0.24, alpha: 1.00)
        case .closed: self.availability.backgroundColor = UIColor(red: 0.76, green: 0.23, blue: 0.14, alpha: 1.00)
        case .unknown: self.availability.backgroundColor = UIColor(red: 0.34, green: 0.60, blue: 0.75, alpha: 1.00)
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
