//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

protocol HeaderCellViewModelInterface {
    var title: String { get }
}

struct HeaderCellViewModel: HeaderCellViewModelInterface {
    let title: String
}
