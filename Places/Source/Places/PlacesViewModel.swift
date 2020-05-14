//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
import RxSwift

struct PlacesViewModel: PlacesViewModelInterface {
    enum ErrorType {
        case unknown
    }

    enum Event {
        case fetchPlaces
        case changeSortCriteria(SortingCriteria)
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
    private let isLoadingSubject = PublishSubject<Bool>()
    private let errorSubject = PublishSubject<ErrorType>()
    private var placesSubject = BehaviorSubject<[Place]>(value: [])
    private var sortingCriteriaSubject = BehaviorSubject<SortingCriteria>(value: .rating)

    init(repository: PlacesRepositoryInterface) {
        self.repository = repository
    }

    func transform(event: Observable<Event>) -> Observable<State> {
        let outputState = event.flatMapLatest(handleEvent)
        let isLoading = isLoadingSubject.map({ State.isLoading($0) })
        let error = errorSubject.map({ State.error($0) })
        return Observable.merge(outputState, isLoading, error)
    }
}

//MARK: - Private methods
private extension PlacesViewModel {
    func handleError(error: Error) {
        //map error -> PlacesVM Error
        errorSubject.onNext(.unknown)
    }

    //MARK: Event handling
    func handleEvent(event: Event) -> Observable<State> {
        print(event)
        switch event {
        case .fetchPlaces:
            return getStateForFetchPlacesEvent()
        case let .changeSortCriteria(criteria):
            return getStateForChangeSortCriteria(criteria: criteria)
        }
    }

    func getStateForFetchPlacesEvent() -> Observable<State> {
        isLoadingSubject.onNext(true)
        return repository
            .getPlaces()
            .do(onSuccess: self.placesSubject.onNext)
            .asObservable()
            .withLatestFrom(sortingCriteriaSubject, resultSelector: sort)
            .do(onNext: { _ in
                print("HEEEEY")
            })
            .stopLoading(loadingSubject: isLoadingSubject)
            .map(mapToPlacesCellViewModel)
            .map(mapToPlacesState)
    }

    func getStateForChangeSortCriteria(criteria: SortingCriteria) -> Observable<State> {
        sortingCriteriaSubject.onNext(criteria)
        return sortingCriteriaSubject
            .debug()
            .withLatestFrom(placesSubject) { (sortingCriteria, places) -> [Place] in
                self.sort(places: places, withCriteria: sortingCriteria)
            }
        .map(mapToPlacesCellViewModel)
        .map(mapToPlacesState)
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
}
