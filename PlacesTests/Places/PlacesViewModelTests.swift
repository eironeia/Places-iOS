//  Created by Alex Cuello Ortiz on 17/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import XCTest
import RxSwift
import RxTest
@testable import Places

final class PlacesViewModelTests: XCTestCase {

    private var scheduler: TestScheduler!
    private var mockRepository: MockPlacesRepository!
    private var mockPlacesCoordinator:MockPlacesCoordinator!
    private var location: Location!
    private var disposeBag: DisposeBag!
    //SUT
    private var viewModel: PlacesViewModelInterface!

    override func setUp() {
        super.setUp()
        mockPlacesCoordinator = MockPlacesCoordinator()
        location = Location(latitude: -33.8669667, longitude: 151.1958862)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        scheduler = nil
        mockRepository = nil
        mockPlacesCoordinator = nil
        location = nil
        viewModel = nil
        disposeBag = nil
        super.tearDown()
    }

    func test_givenPlacesViewModel_whenFetchPlacesEvent_and_successResponse_thenPlacesState() {
        mockRepository = MockPlacesRepository(response: .success)
        viewModel = makeSUT()

        let eventSubject: TestableObservable<PlacesViewModel.Event> = scheduler
            .createHotObservable([
                .next(10, PlacesViewModel.Event.fetchPlaces(location))
            ])

        let state = viewModel.transform(event: eventSubject.asObservable())
        let stateResultSubject = scheduler.createObserver(PlacesViewModel.State.self)
        state.bind(to: stateResultSubject).disposed(by: disposeBag)

        scheduler.start()

        let expectedStateEvents: [Recorded<Event<PlacesViewModel.State>>] = [
            .next(10, .isLoading(true)),
            .next(10, .isLoading(false)),
            .next(10, mockRepository.getPlacesFromMock(with: .success).places.mapToPlacesState()),
        ]
        XCTAssertEqual(stateResultSubject.events, expectedStateEvents)
    }

    func test_givenPlacesViewModel_whenFetchPlacesEvent_and_zeroResultsResponse_thenPlacesState() {
        mockRepository = MockPlacesRepository(response: .noResults)
        viewModel = makeSUT()

        let eventSubject: TestableObservable<PlacesViewModel.Event> = scheduler
            .createHotObservable([
                .next(10, PlacesViewModel.Event.fetchPlaces(location))
            ])

        let state = viewModel.transform(event: eventSubject.asObservable())
        let stateResultSubject = scheduler.createObserver(PlacesViewModel.State.self)
        state.bind(to: stateResultSubject).disposed(by: disposeBag)

        scheduler.start()

        let expectedStateEvents: [Recorded<Event<PlacesViewModel.State>>] = [
            .next(10, .isLoading(true)),
            .next(10, .isLoading(false)),
            .next(10, .places([])),
        ]
        XCTAssertEqual(stateResultSubject.events, expectedStateEvents)
    }

    func test_givenPlacesViewModel_whenFetchPlacesEvent_and_overQuotaResponse_thenPlacesState() {
        mockRepository = MockPlacesRepository(response: .overQuota)
        viewModel = makeSUT()

        let eventSubject: TestableObservable<PlacesViewModel.Event> = scheduler
            .createHotObservable([
                .next(10, PlacesViewModel.Event.fetchPlaces(location))
            ])

        let state = viewModel.transform(event: eventSubject.asObservable())
        let stateResultSubject = scheduler.createObserver(PlacesViewModel.State.self)
        state.bind(to: stateResultSubject).disposed(by: disposeBag)

        scheduler.start()

        let expectedStateEvents: [Recorded<Event<PlacesViewModel.State>>] = [
            .next(10, .isLoading(true)),
            .next(10, .isLoading(false)),
            .next(10, .error(.generic))
        ]
        XCTAssertEqual(stateResultSubject.events, expectedStateEvents)
    }

    func test_givenPlacesViewModel_whenFetchPlacesEvent_and_RequestDeniedResponse_thenPlacesState() {
        mockRepository = MockPlacesRepository(response: .requestDenied)
        viewModel = makeSUT()

        let eventSubject: TestableObservable<PlacesViewModel.Event> = scheduler
            .createHotObservable([
                .next(10, PlacesViewModel.Event.fetchPlaces(location))
            ])

        let state = viewModel.transform(event: eventSubject.asObservable())
        let stateResultSubject = scheduler.createObserver(PlacesViewModel.State.self)
        state.bind(to: stateResultSubject).disposed(by: disposeBag)

        scheduler.start()

        let expectedStateEvents: [Recorded<Event<PlacesViewModel.State>>] = [
            .next(10, .isLoading(true)),
            .next(10, .isLoading(false)),
            .next(10, .error(.generic))
        ]
        XCTAssertEqual(stateResultSubject.events, expectedStateEvents)
    }

    func test_givenPlacesViewModel_whenPlaceTapped_thenCoordinatorCalled() {
        let expectation = self.expectation(description: "To places details called")
        mockRepository = MockPlacesRepository(response: .success)
        mockPlacesCoordinator = MockPlacesCoordinator(toPlacesDetailsCalled: {
            expectation.fulfill()
        })

        viewModel = makeSUT()

        let eventSubject: TestableObservable<PlacesViewModel.Event> = scheduler
            .createHotObservable([
                .next(10, PlacesViewModel.Event.fetchPlaces(location)),
                .next(20, PlacesViewModel.Event.placeTapped(IndexPath(row: 0, section: 0)))
            ])

        let state = viewModel.transform(event: eventSubject.asObservable())
        let stateResultSubject = scheduler.createObserver(PlacesViewModel.State.self)
        state.bind(to: stateResultSubject).disposed(by: disposeBag)

        scheduler.start()

        let expectedStateEvents: [Recorded<Event<PlacesViewModel.State>>] = [
            .next(10, .isLoading(true)),
            .next(10, .isLoading(false)),
            .next(10, mockRepository.getPlacesFromMock(with: .success).places.mapToPlacesState()),
            .next(20, .idle),
        ]
        XCTAssertEqual(stateResultSubject.events, expectedStateEvents)
        waitForExpectations(timeout: 0.5, handler: nil)
    }
}

private extension PlacesViewModelTests {
    func makeSUT() -> PlacesViewModelInterface {
        PlacesViewModel(repository: mockRepository,
                        router: mockPlacesCoordinator)
    }
}

extension PlacesViewModel.State: Equatable {
    public static func == (lhs: PlacesViewModel.State, rhs: PlacesViewModel.State) -> Bool {
        switch (lhs, rhs) {
        case let (isLoading(isLoading1),isLoading(isLoading2)): return isLoading1 == isLoading2
        case let (error(error1), error(error2)): return error1 == error2
        case let (places(viewModels1), places(viewModels2)): return viewModels1.count == viewModels2.count
        case (idle, idle): return true
        default: return false
        }
    }
}
