//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
import RxSwift

struct PlaceDetailsViewModel: PlaceDetailsViewModelInterface {
    enum Event {
        case fetchPlaceDetails
    }

    enum State {
        case sections([SectionType])
    }

    enum SectionType {
        case header(HeaderCellViewModelInterface)
        case details([DetailsCellViewModel])
    }

    private let place: Place

    init(place: Place) {
        self.place = place
    }

    func transform(event: Observable<Event>) -> Observable<State> {
        let outputState = event.flatMapLatest(handleEvent)
        return Observable.merge(outputState)
    }
}

//MARK: - Private methods
private extension PlaceDetailsViewModel {
    func handleEvent(event: Event) -> Observable<State> {
        switch event {
        case .fetchPlaceDetails:
            return getStateForFetchPlaceDetailsEvent()
        }
    }

    func getStateForFetchPlaceDetailsEvent() -> Observable<State> {
        return .just(
            .sections(
                [.header(HeaderCellViewModel(title: place.name)),
                 .details([
                    DetailsCellViewModel(
                        detailsTitle: "Availability 🗓",
                        details: getAvailabilityDetails(isOpen: place.openingHours?.isOpen)
                    ),
                    DetailsCellViewModel(
                        detailsTitle: "Rating ⭐️",
                        details: getRatingDetails(rating: place.rating)
                    ),
                    DetailsCellViewModel(
                        detailsTitle: "Total user reviews 👥",
                        details: getUserRatingTotalDetails(totalOfReviews: place.userRatingsTotal)
                    ),
                    DetailsCellViewModel(
                        detailsTitle: "Price level 🤑",
                        details: getPriceLevellDetails(priceLevel: place.priceLevel)
                    )])
                ]
            )
        )
    }

    func getAvailabilityDetails(isOpen: Bool?) -> String {
        guard let isOpen = isOpen else { return PlaceCellViewModel.Availability.unknown.rawValue }
        return isOpen
            ? PlaceCellViewModel.Availability.open.rawValue
            : PlaceCellViewModel.Availability.closed.rawValue
    }

    func getRatingDetails(rating: Double?) -> String {
        if let rating = rating {
            return "\(rating)"
        } else {
            return "-"
        }
    }

    func getUserRatingTotalDetails(totalOfReviews: Int?) -> String {
        if let totalOfReviews = totalOfReviews {
            return "\(totalOfReviews)"
        } else {
            return "-"
        }
    }

    func getPriceLevellDetails(priceLevel: Int?) -> String {
        if let priceLevel = priceLevel {
            return String(repeating: "€", count: priceLevel)
        } else {
            return "-"
        }
    }
}
