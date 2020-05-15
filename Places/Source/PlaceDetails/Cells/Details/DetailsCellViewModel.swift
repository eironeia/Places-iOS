//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

protocol DetailsCellViewModelInterface {
    var detailsTitle: String { get }
    var details: String { get }
}

struct DetailsCellViewModel: DetailsCellViewModelInterface {
    let detailsTitle: String
    let details: String
    init(detailsTitle: String, details: String) {
        self.detailsTitle = detailsTitle
        self.details = details
    }
}
