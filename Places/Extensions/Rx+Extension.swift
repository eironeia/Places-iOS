//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.
// swiftlint:disable line_length
//  Source: https://github.com/sergdort/CleanArchitectureRxSwift/blob/master/CleanArchitectureRxSwift/Utility/Observable%2BExt.swift

import Foundation
import RxCocoa
import RxSwift

extension ObservableType where Element == Bool {
    /// Boolean not operator
    public func not() -> Observable<Bool> {
        map(!)
    }
}

extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        map { _ in }
    }
}

extension ObservableType {
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        asDriver { _ in
            Driver.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        map { _ in }
    }

    func stopLoading(loadingSubject: PublishSubject<Bool>) -> Observable<Element> {
        self
            .do(onNext: { _ in loadingSubject.onNext(false) },
                onError: { _ in loadingSubject.onNext(false) })
    }
}
