//
//  CanvasTool.swift
//  DrawingCanvas
//
//  Created by Yu Sugawara on 3/16/17.
//  Copyright © 2017 Yu Sugawara. All rights reserved.
//

import UIKit

public enum DrawingTool {
    case pen
    case eraser
    case line
    
    public func drawingPath(startPoint: CGPoint, brush: Brush) -> DrawablePath {
        switch self {
        case .pen:
            return DrawingPath(startPoint: startPoint, brush: brush)
        case .eraser:
            return DrawingPath(startPoint: startPoint,
                               brush: Brush.eraser(lineWidth: brush.lineWidth,
                                                   lineCap: brush.lineCap))
        case .line:            
            return DrawingLine(startPoint: startPoint, brush: brush)
        }
    }
}
