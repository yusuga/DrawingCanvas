//
//  Drawable.swift
//  DrawingCanvas
//
//  Created by Yu Sugawara on 3/14/17.
//  Copyright © 2017 Yu Sugawara. All rights reserved.
//

import Foundation

public protocol Drawable: NSCopying, NSCoding {
    func draw(in context: CGContext)
}
