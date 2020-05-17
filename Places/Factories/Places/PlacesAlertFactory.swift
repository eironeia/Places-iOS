//  Created by Alex Cuello Ortiz on 12/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import UIKit

struct PlacesAlertFactory: PlacesAlertFactoryInterface {
    func makeRestrictedAlert(action: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(
            title: "Resricted location",
            message: "Location is being restricted. Probably, due to parental restrictions.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: action))

        return alert
    }

    func makeDeniedAlert(action: ((UIAlertAction) -> Void)?) -> UIAlertController {

        let message = [
            "Possible reasons:",
            "Location permissions has been denied.",
            "Location services are off for the device in Settings.",
            "Unavailable because the device is in Airplane mode."
        ].joined(separator: "\n")

        let alert = UIAlertController(
            title: "Location disabled",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Take me to settings", style: .default, handler: action))

        return alert
    }

    func makeErrorAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        return alert
    }

    func makeSortingCriteriaAlert(
        rating: ((UIAlertAction) -> Void)?,
        availability: ((UIAlertAction) -> Void)?
    ) -> UIAlertController {

        let alert = UIAlertController(
            title: "Sort list",
            message: "Chose a sorting criteria method.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Rating ⭐️", style: .default, handler: rating))
        alert.addAction(UIAlertAction(title: "Availability 🗓", style: .default, handler: availability))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: availability))

        return alert
    }
}
