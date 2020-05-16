//  Created by Alex Cuello Ortiz on 16/05/2020.
//  Copyright © 2020 Chama. All rights reserved.

import Foundation

extension Bundle {
    public class var mockAPI: Bundle {
        guard let bundlePath = Bundle.main.path(forResource: "MockAPI", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath) else {
                fatalError()
        }
        return bundle
    }
}
