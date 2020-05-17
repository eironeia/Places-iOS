//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
import RxSwift

struct PlacesViewModel {
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
}

// MARK: - PlacesViewModel Interface

extension PlacesViewModel: PlacesViewModelInterface {
    func transform(event: Observable<Event>) -> Observable<State> {
        let outputState = event.flatMapLatest(handleEvent)
        let isLoading = isLoadingSubject.map(State.isLoading)
        return Observable.merge(outputState, isLoading)
    }
}

// MARK: - Private methods

private extension PlacesViewModel {
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

    func monitorError(error: Error) {
        debugPrint(error.localizedDescription)
    }
}

// MARK: - Fetch places event

private extension PlacesViewModel {
    func getStateForFetchPlacesEvent(with location: Location) -> Observable<State> {
        isLoadingSubject.onNext(true)
        return repository
            .getPlaces(with: location)
            .asObservable()
            .withLatestFrom(sortingCriteriaSubject, resultSelector: mapToSortedPlacesResult)
            .savePlacesIfSuccess(to: placesSubject)
            .mapToState()
            .stopLoading(loadingSubject: isLoadingSubject)
    }

    func mapToSortedPlacesResult(
        response: GetPlacesResponse,
        sortingCriteria: SortingCriteria
    ) -> Result<[Place], ErrorType> {
        switch response.status {
        case .success, .noResults:
            return .success(
                response.places.sortedBy(sortingCriteria: sortingCriteria)
            )
        case .invalidRequest, .overQuota, .requestDenied, .unknown:
            return .failure(.generic)
        }
    }
}

// MARK: - Change sort criteria event

private extension PlacesViewModel {
    func getStateForChangeSortCriteria(criteria: SortingCriteria) -> Observable<State> {
        sortingCriteriaSubject.onNext(criteria)
        return sortingCriteriaSubject
            .withLatestFrom(placesSubject) { (sortingCriteria, places) -> [Place] in
                places.sortedBy(sortingCriteria: sortingCriteria)
            }
            .do(onNext: placesSubject.onNext)
            .map { $0.mapToPlacesState() }
    }
}

// MARK: - Place tapped event

private extension PlacesViewModel {
    func getStateForPlaceTapped(index: IndexPath) -> Observable<State> {
        Observable
            .just(index)
            .withLatestFrom(placesSubject) { (indexPath, places) -> Void in
                guard let place = places[safe: indexPath.row] else { return assertionFailure("Index out of bounds.") }
                self.router.toPlaceDetails(place: place)
            }
            .map { .idle }
    }
}

extension ObservableType where Element == Result<[Place], PlacesViewModel.ErrorType> {
    func mapToState() -> Observable<PlacesViewModel.State> {
        map { result in
            switch result {
            case let .success(places):
                return places.mapToPlacesState()
            case let .failure(error):
                return .error(error)
            }
        }
    }

    func savePlacesIfSuccess(to storage: BehaviorSubject<[Place]>) -> Observable<Element> {
        self.do(onNext: { result in
            guard case let .success(places) = result else { return }
            storage.onNext(places)
        })
    }
}
