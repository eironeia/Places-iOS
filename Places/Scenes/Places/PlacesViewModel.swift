//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
import RxSwift

struct PlacesViewModel: PlacesViewModelInterface {
    enum ErrorType: Error {
        case generic

        var information: (title: String, message: String) {
            switch self {
            case .generic: return ("Oops!", "Something went wrong.")
            }
        }
    }

    enum Event {
        case fetchPlaces(Location)
        case changeSortCriteria(SortingCriteria)
        case placeTapped(IndexPath)
    }

    enum State {
        case isLoading(Bool)
        case places([PlaceCellViewModelInterface])
        case error(ErrorType)
        case idle
    }

    enum SortingCriteria {
        case rating
        case availability
    }

    private let repository: PlacesRepositoryInterface
    private let router: PlacesCoordinatorInterface
    private let isLoadingSubject = PublishSubject<Bool>()
    private let placesSubject = BehaviorSubject<[Place]>(value: [])
    private let sortingCriteriaSubject = BehaviorSubject<SortingCriteria>(value: .rating)

    init(repository: PlacesRepositoryInterface, router: PlacesCoordinatorInterface) {
        self.repository = repository
        self.router = router
    }

    func transform(event: Observable<Event>) -> Observable<State> {
        let outputState = event.flatMapLatest(handleEvent)
        let isLoading = isLoadingSubject.map(State.isLoading)
        return Observable.merge(outputState, isLoading)
    }
}

// MARK: - Private methods

private extension PlacesViewModel {
    // MARK: Event handling

    func handleEvent(event: Event) -> Observable<State> {
        switch event {
        case let .fetchPlaces(location):
            return getStateForFetchPlacesEvent(with: location)
        case let .changeSortCriteria(criteria):
            return getStateForChangeSortCriteria(criteria: criteria)
        case let .placeTapped(index):
            return getStateForPlaceTapped(index: index)
        }
    }

    func getStateForFetchPlacesEvent(with location: Location) -> Observable<State> {
        isLoadingSubject.onNext(true)
        return repository
            .getPlaces(with: location)
            .asObservable()
            .withLatestFrom(sortingCriteriaSubject, resultSelector: mapToState)
            .stopLoading(loadingSubject: isLoadingSubject)
    }

    func mapToState(placesResponse: GetPlacesResponse, sortingCriteria: SortingCriteria) -> State {
        switch placesResponse.status {
        case .success, .noResults:
            let places = placesResponse.places
            let sortedPlaces = sort(places: places, withCriteria: sortingCriteria)
            placesSubject.onNext(places)
            let cellViewModels = mapToPlacesCellViewModel(places: sortedPlaces)
            return .places(cellViewModels)
        case .invalidRequest, .overQuota, .requestDenied, .unknown:
            return .error(.generic)
        }
    }

    func getStateForChangeSortCriteria(criteria: SortingCriteria) -> Observable<State> {
        sortingCriteriaSubject.onNext(criteria)
        return sortingCriteriaSubject
            .withLatestFrom(placesSubject) { (sortingCriteria, places) -> [Place] in
                self.sort(places: places, withCriteria: sortingCriteria)
            }
            .do(onNext: placesSubject.onNext)
            .map(mapToPlacesCellViewModel)
            .map(mapToPlacesState)
    }

    func getStateForPlaceTapped(index: IndexPath) -> Observable<State> {
        Observable
            .just(index)
            .withLatestFrom(placesSubject) { (indexPath, places) -> Void in
                guard let place = places[safe: indexPath.row] else { return assertionFailure("Index out of bounds.") }
                self.router.toPlaceDetails(place: place)
            }
            .map { _ in .idle }
    }

    // MARK: Sort methods

    func sort(places: [Place], withCriteria sortingCriteria: SortingCriteria) -> [Place] {
        switch sortingCriteria {
        case .rating:
            return sortPlacesByRating(places: places)
        case .availability:
            return sortPlacesByAvailability(places: places)
        }
    }

    func sortPlacesByRating(places: [Place]) -> [Place] {
        places.sorted { (place1, place2) -> Bool in
            switch (place1.rating, place2.rating) {
            case (nil, nil): return true
            case(nil, _): return false
            case(_, nil): return true
            case let (rating1, rating2):
                guard let r1 = rating1, let r2 = rating2 else { assertionFailure("This should never be triggered."); return false }
                return r1 > r2
            }
        }
    }

    func sortPlacesByAvailability(places: [Place]) -> [Place] {
        places.sorted { (place1, place2) -> Bool in
            switch (place1.openingHours?.isOpen, place2.openingHours?.isOpen) {
            case (nil, nil): return true
            case(nil, _): return false
            case(_, nil): return true
            case let (isOpen1, _):
                return isOpen1 ?? false
            }
        }
    }

    // MARK: Mapping

    func mapToPlacesCellViewModel(places: [Place]) -> [PlaceCellViewModel] {
        places.map(PlaceCellViewModel.init)
    }

    func mapToPlacesState(viewModels: [PlaceCellViewModel]) -> State {
        .places(viewModels)
    }

    // MARK: Error monitoring

    func monitorError(error: Error) {
        debugPrint(error.localizedDescription)
    }
}
