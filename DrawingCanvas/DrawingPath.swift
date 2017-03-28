//
//  DrawingPath.swift
//  DrawingCanvas
//
//  Created by Yu Sugawara on 3/14/17.
//  Copyright © 2017 Yu Sugawara. All rights reserved.
//

import Foundation

public class DrawingPath: Path, DrawablePath {
    
    // MARK: - Properties
    
    private var pointIndex = 0
    private var points = [CGPoint?](repeating: CGPoint.zero, count: 5)
        
    // MARK: - Initializers
    
    public convenience init(startPoint: CGPoint, brush: Brush) {
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: startPoint)
        self.init(bezierPath: path, brush: brush)
    }
    
    internal override init(bezierPath: UIBezierPath, brush: Brush) {
        points[0] = bezierPath.cgPath.currentPoint
        super.init(bezierPath: bezierPath, brush: brush)
    }
    
    // MARK: - DrawablePath
    
    public func addPoint(_ point: CGPoint) {
        if !brush.isSmoothDrawing {
            bezierPath.addLine(to: point)
            return
        }
        
        /*
         Smooth Freehand Drawing on iOS
         https://code.tutsplus.com/tutorials/smooth-freehand-drawing-on-ios--mobile-13164
         */
        
        pointIndex += 1
        points[pointIndex] = point
        
        if pointIndex == 4 {
            // move the endpoint to the middle of the line joining the second control point of the first Bezier segment
            // and the first control point of the second Bezier segment
            points[3] = CGPoint(x: (points[2]!.x + points[4]!.x)/2.0, y: (points[2]!.y + points[4]!.y) / 2.0)
            
            // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
            bezierPath.move(to: points[0]!)
            bezierPath.addCurve(to: points[3]!, controlPoint1: points[1]!, controlPoint2: points[2]!)
            
            // replace points and get ready to handle the next segment
            points[0] = points[3]
            points[1] = points[4]
            pointIndex = 1
        }
    }
}
