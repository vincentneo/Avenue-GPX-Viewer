//
//  NSSize+Multiplier.swift
//  Avenue
//
//  Created by Vincent Neo on 5/8/22.
//  Copyright © 2022 Vincent. All rights reserved.
//

import AppKit

extension CGSize {
    func multiplied(_ factor: Double) -> CGSize {
        return CGSize(width: self.width * factor, height: self.height * factor)
    }
}
