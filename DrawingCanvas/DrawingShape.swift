//
//  DrawingShape.swift
//  DrawingCanvas
//
//  Created by Yu Sugawara on 3/16/17.
//  Copyright © 2017 Yu Sugawara. All rights reserved.
//

import Foundation

public class DrawingShape: Path {
    
    // MARK: - Properties
    
    internal let startPoint: CGPoint
    
    // MARK: - Initializers
    
    public convenience init(startPoint: CGPoint, brush: Brush) {
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: startPoint)        
        self.init(bezierPath: path, brush: brush)
    }
    
    internal override init(bezierPath: UIBezierPath, brush: Brush) {
        startPoint = bezierPath.cgPath.currentPoint
        super.init(bezierPath: bezierPath, brush: brush)
    }
}
