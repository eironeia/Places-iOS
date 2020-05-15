//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
import RxSwift
import RxCocoa

//MARK: PlaceDetails ViewModel
protocol PlaceDetailsViewModelInterface {
    func transform(event: Observable<PlaceDetailsViewModel.Event>) -> Observable<PlaceDetailsViewModel.State>
}
