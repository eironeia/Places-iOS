//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
import RxSwift

// swiftlint:disable line_length
// Inspired by: https://medium.com/@jamesrochabrun/protocol-based-generic-networking-using-jsondecoder-and-decodable-in-swift-4-fc9e889e8081
protocol APIClientInterface {
    var session: URLSession { get }
    func rxRequest<T: Decodable>(with request: URLRequest) -> Single<T>
}

extension APIClientInterface {
    typealias JSONTaskCompletionHandler = (Result<Decodable, APIError>) -> Void
    private func decodingTask<T: Decodable>(
        with request: URLRequest,
        decodingType: T.Type,
        completionHandler
        completion: @escaping JSONTaskCompletionHandler
    ) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.requestFailed))
            }
            guard (200 ... 299).contains(httpResponse.statusCode) else {
                return completion(.failure(.responseUnsuccessful))
            }

            guard let data = data else {
                return completion(.failure(.invalidData))
            }

            do {
                let genericModel = try JSONDecoder().decode(decodingType, from: data)
                completion(.success(genericModel))
            } catch {
                completion(.failure(.jsonConversionFailure))
            }
        }
        return task
    }

    func rxRequest<T: Decodable>(with request: URLRequest) -> Single<T> {
        .create { single in
            let task = self.decodingTask(with: request, decodingType: T.self) { result in
                switch result {
                case let .success(json):
                    if let value = json as? T {
                        single(.success(value))
                    } else {
                        single(.error(APIError.jsonParsingFailure))
                    }
                case let .failure(error):
                    single(.error(error))
                }
            }
            task.resume()
            return Disposables.create()
        }
    }
}
