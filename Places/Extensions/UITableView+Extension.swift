//  Created by Alex Cuello Ortiz on 17/05/2020.
//  Copyright © 2020 Chama. All rights reserved

import UIKit

extension UITableView {
    func cell<T: Reusable>(as _: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier) as? T else {
            fatalError("Cell has not been registered.")
        }
        return cell
    }
}
