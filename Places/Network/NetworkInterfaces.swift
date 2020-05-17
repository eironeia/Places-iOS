//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation
import RxSwift

// MARK: - Endpoint

protocol EndpointInterface {
    var base: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension EndpointInterface {
    var apiKey: URLQueryItem {
        guard let key = ProcessInfo.processInfo.environment["PLACES_API_KEY"] else { fatalError("Missing API key") }
        return URLQueryItem(name: "key", value: key)
    }

    var urlComponents: URLComponents {
        var components = URLComponents(string: base)!
        components.path = path
        components.queryItems = queryItems
        return components
    }

    var request: URLRequest {
        let url = urlComponents.url!
        return URLRequest(url: url)
    }
}

// MARK: - API

// swiftlint:disable line_length
// Inspired by: https://medium.com/@jamesrochabrun/protocol-based-generic-networking-using-jsondecoder-and-decodable-in-swift-4-fc9e889e8081
protocol APIClient {
    var session: URLSession { get }
    func rxRequest<T: Decodable>(with request: URLRequest) -> Single<T>
}

extension APIClient {
    typealias JSONTaskCompletionHandler = (Decodable?, APIError?) -> Void
    private func decodingTask<T: Decodable>(
        with request: URLRequest,
        decodingType: T.Type,
        completionHandler
        completion: @escaping JSONTaskCompletionHandler
    ) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            guard httpResponse.statusCode == 200 else {
                completion(nil, .responseUnsuccessful)
                return
            }

            guard let data = data else {
                completion(nil, .invalidData)
                return
            }

            do {
                let genericModel = try JSONDecoder().decode(decodingType, from: data)
                completion(genericModel, nil)
            } catch {
                completion(nil, .jsonConversionFailure)
            }
        }
        return task
    }

    func rxRequest<T: Decodable>(with request: URLRequest) -> Single<T> {
        return .create { single in
            let task = self.decodingTask(with: request, decodingType: T.self) { json, error in
                guard let json = json else {
                    if let error = error {
                        single(.error(error))
                    } else {
                        single(.error(APIError.invalidData))
                    }
                    return
                }

                if let value = json as? T {
                    single(.success(value))
                } else { single(.error(APIError.jsonParsingFailure)) }
            }
            task.resume()
            return Disposables.create()
        }
    }
}
