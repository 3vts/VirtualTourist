//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Alvaro Santiesteban on 9/20/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
