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
    private let errorSubject = PublishSubject<ErrorType>()
    private let placesSubject = BehaviorSubject<[Place]>(value: [])
    private let sortingCriteriaSubject = BehaviorSubject<SortingCriteria>(value: .rating)

    init(repository: PlacesRepositoryInterface, router: PlacesCoordinatorInterface) {
        self.repository = repository
        self.router = router
    }

    func transform(event: Observable<Event>) -> Observable<State> {
        let outputState = event.flatMapLatest(handleEvent)
        let isLoading = isLoadingSubject.map(State.isLoading)
        let error = errorSubject.map(State.error)
        return Observable.merge(outputState, isLoading, error)
    }
}

//MARK: - Private methods
private extension PlacesViewModel {
    //MARK: Event handling
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
            .flatMap({ placesResponse -> Single<[Place]> in
                guard case GetPlacesResponse.StatusCode.success = placesResponse.status else {
                    debugPrint(placesResponse.status.localizedDescription)
                    return .error(ErrorType.generic)
                }
                return .just(placesResponse.places)
            })
            .do(onError: handleError)
            .asObservable()
            .withLatestFrom(sortingCriteriaSubject, resultSelector: sort)
            .do(onNext: self.placesSubject.onNext)
            .stopLoading(loadingSubject: isLoadingSubject)
            .map(mapToPlacesCellViewModel)
            .map(mapToPlacesState)
    }

    func getStateForChangeSortCriteria(criteria: SortingCriteria) -> Observable<State> {
        sortingCriteriaSubject.onNext(criteria)
        return sortingCriteriaSubject
            .withLatestFrom(placesSubject) { (sortingCriteria, places) -> [Place] in
                self.sort(places: places, withCriteria: sortingCriteria)
        }
        .do(onNext: self.placesSubject.onNext)
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
        .map({ _ in .idle })
    }


    //MARK: Sort methods
    func sort(places: [Place], withCriteria sortingCriteria: SortingCriteria) -> [Place] {
        switch sortingCriteria {
        case .rating:
            return self.sortPlacesByRating(places: places)
        case .availability:
            return self.sortPlacesByAvailability(places: places)
        }
    }

    func sortPlacesByRating(places: [Place]) -> [Place] {
        places.sorted { (place1, place2) -> Bool in
            switch (place1.rating,place2.rating) {
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
            switch (place1.openingHours?.isOpen,place2.openingHours?.isOpen) {
            case (nil, nil): return true
            case(nil, _): return false
            case(_, nil): return true
            case let (isOpen1, _):
                return isOpen1 ?? false
            }
        }
    }

    //MARK: Mapping
    func mapToPlacesCellViewModel(places: [Place]) -> [PlaceCellViewModel] {
        places.map(PlaceCellViewModel.init)
    }

    func mapToPlacesState(viewModels: [PlaceCellViewModel]) -> State {
        .places(viewModels)
    }

    //MARK: Error handling
    func handleError(error: Error) {
        debugPrint(error.localizedDescription)
        if let error = error as? APIError {
            handleAPIError(error)
        } else if let error = error as? GetPlacesResponse.StatusCode {
            handleGetPlacesStatusCode(error)
        } else {
            errorSubject.onNext(.generic)
        }
    }

    func handleAPIError(_ error: APIError) {
        switch error {
        case .requestFailed:
            errorSubject.onNext(.generic)
        case .jsonConversionFailure:
            debugPrint("Wrong model type while decoding JSON.")
            errorSubject.onNext(.generic)
        case .invalidData:
            debugPrint("Invalid data")
            errorSubject.onNext(.generic)
        case .responseUnsuccessful:
            errorSubject.onNext(.generic)
        case .jsonParsingFailure:
            debugPrint("Error parsing JSON.")
            errorSubject.onNext(.generic)
        }
    }

    func handleGetPlacesStatusCode(_ statusCode: GetPlacesResponse.StatusCode) {
        switch statusCode {
        case .success: break
        case .noResults, .overQuota, .requestDenied, .invalidRequest, .unknown:
            debugPrint(statusCode.localizedDescription)
            errorSubject.onNext(.generic)
        }
    }
}
