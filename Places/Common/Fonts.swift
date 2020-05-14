//  Created by Alex Cuello Ortiz on 14/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

enum CircleRoundedFontType {
    case regular
    case semiBold
    case bold
}

enum FontSize {
    static var small: CGFloat = 14
    static var `default`: CGFloat = 16
    static var double: CGFloat = 18
    static var big: CGFloat = 20
}

extension UIFont {
    static func circleRoundedFont(size: CGFloat = FontSize.default, type: CircleRoundedFontType = .regular) -> UIFont {
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
