//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Ramon Geronimo on 9/5/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import Foundation
import UIKit

// MARK: GCD BlackBox
func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    
    DispatchQueue.main.async {
        updates()
    }
}
