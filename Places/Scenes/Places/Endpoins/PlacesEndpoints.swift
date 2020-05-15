//  Created by Alex Cuello Ortiz on 15/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

enum PlacesEndpoint {
    case nearbyPlaces
}

extension PlacesEndpoint: EndpointInterface {
    var queryItems: [URLQueryItem] {
        [
            apiKey,
            URLQueryItem(name: "location", value: "51.50998000,-0.13370000"),
            URLQueryItem(name: "rankby", value: "distance"),
            URLQueryItem(name: "type", value: "bar,restaurant,cafe"),
        ]
    }

    var base: String {
        return "https://maps.googleapis.com"
    }

    var path: String {
        switch self {
        case .nearbyPlaces: return "/maps/api/place/nearbysearch/json"
        }
    }
}
