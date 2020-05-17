//  Created by Alex Cuello Ortiz on 14/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

extension UIFont {
    enum CircleRoundedFontType {
        case regular
        case semiBold
        case bold
    }

    static func circleRoundedFont(size: CGFloat = Constants.FontSize.default, type: CircleRoundedFontType = .regular) -> UIFont {
        let fontName: String

        switch type {
        case .regular:
            fontName = "CirceRounded-Regular"
        case .semiBold:
            fontName = "CirceRounded-Regular4"
        case .bold:
            fontName = "CirceRounded-Regular3"
        }

        guard let customFont = UIFont(name: fontName, size: size) else {
            fatalError("Failed to load the \(fontName) font.")
        }
        return customFont
    }
}
