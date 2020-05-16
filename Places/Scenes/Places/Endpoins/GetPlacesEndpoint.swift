//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

struct GetPlacesEndpoint: GetPlacesEndpointInterface {
    var queryItems: [URLQueryItem] = []
    init(location: Location) {
        queryItems = [
            apiKey,
            URLQueryItem(name: "location", value: "\(location.latitude),\(location.longitude)"),
            URLQueryItem(name: "rankby", value: "distance"),
            URLQueryItem(name: "type", value: "bar,restaurant,cafe"),
        ]
    }
}
