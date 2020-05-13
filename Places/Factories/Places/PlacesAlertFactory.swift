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

    func makeDeniedAlert(
        okAction: ((UIAlertAction) -> Void)?,
        goSettingsAction: ((UIAlertAction) -> Void)?
    ) -> UIAlertController {

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

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: okAction))
        alert.addAction(UIAlertAction(title: "Take me to settings", style: .default, handler: goSettingsAction))

        return alert
    }
}
