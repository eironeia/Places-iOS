//  Created by Alex Cuello Ortiz on 17/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

extension UIAlertController {
    func present(on viewController: UIViewController, animated: Bool = true) {
        viewController.present(self, animated: animated, completion: nil)
    }
}
