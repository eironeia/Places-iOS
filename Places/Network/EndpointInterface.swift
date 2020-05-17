//  Created by Alex Cuello Ortiz on 17/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

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

    var urlComponents: URLComponents? {
        var components = URLComponents(string: base)
        components?.path = path
        components?.queryItems = queryItems
        return components
    }

    var request: URLRequest? {
        guard let url = urlComponents?.url else { return nil }
        return URLRequest(url: url)
    }
}
