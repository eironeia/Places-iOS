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
    }

    enum State {
        case isLoading(Bool)
        case places([PlaceCellViewModelInterface])
        case error(ErrorType)
    }

    private let repository: PlacesRepositoryInterface
    private let isLoadingSubject = PublishSubject<Bool>()
    private let errorSubject = PublishSubject<ErrorType>()

    init(repository: PlacesRepositoryInterface) {
        self.repository = repository
    }

    func transform(event: Observable<Event>) -> Observable<State> {
        let places = event.flatMapLatest(handleEvent)
        let isLoading = isLoadingSubject.map({ State.isLoading($0) })
        let error = errorSubject.map({ State.error($0) })
        return Observable.merge(places, isLoading, error)
    }
}

private extension PlacesViewModel {
    func handleError(error: Error) {
        //map error -> PlacesVM Error
        errorSubject.onNext(.unknown)
    }

    func handleEvent(event: Event) -> Observable<State> {
        switch event {
        case .fetchPlaces:
            return handleFetchPlaces()
        }
    }

    func handleFetchPlaces() -> Observable<State> {
        isLoadingSubject.onNext(true)
        return repository
            .getPlaces()
            .asObservable()
            .stopLoading(loadingSubject: isLoadingSubject)
            .map({ $0.map(PlaceCellViewModel.init) })
            .map({ .places($0) })
    }
}
