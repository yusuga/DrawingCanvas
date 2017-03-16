//
//  DrawingLine.swift
//  DrawingCanvas
//
//  Created by Yu Sugawara on 3/16/17.
//  Copyright © 2017 Yu Sugawara. All rights reserved.
//

import Foundation

public class DrawingLine: DrawingShape, DrawablePath {
    
    // MARK: - DrawablePath
    
    public func addPoint(_ point: CGPoint) {
        bezierPath.removeAllPoints()
        bezierPath.move(to: startPoint)
        bezierPath.addLine(to: point)
    }
}
