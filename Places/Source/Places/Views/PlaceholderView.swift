//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

final class PlaceholderView: UIView {
    private let title: UILabel = {
        let label = UILabel()
        label.font = .circleRoundedFont(size: 28, type: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    func setup(text: String) {
        title.text = text
    }
}

private extension PlaceholderView {
    func setupLayout() {
        backgroundColor = .customYellow
        addSubviewWithAutolayout(title)
        title.anchorCenterYToSuperview()
        title.anchor(
            left: leftAnchor,
            right: rightAnchor,
            leftConstant: Spacing.default,
            rightConstant: Spacing.default
        )
    }
}
