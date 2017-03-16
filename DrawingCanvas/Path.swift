//
//  Path.swift
//  DrawingCanvas
//
//  Created by Yu Sugawara on 3/14/17.
//  Copyright © 2017 Yu Sugawara. All rights reserved.
//

import Foundation

public class Path: NSObject, Drawable {
    
    // MARK: - Properties
    
    internal let bezierPath: UIBezierPath
    internal let brush: Brush
    
    // MARK: - Initializers
    
    public init(bezierPath: UIBezierPath, brush: Brush) {
        self.bezierPath = bezierPath
        self.brush = brush
    }
    
    // MARK: - Drawable
    
    public func draw(in context: CGContext) {
        context.saveGState()
        
        context.setAllowsAntialiasing(true)
        context.setStrokeColor(red: CGFloat(brush.red),
                               green: CGFloat(brush.green),
                               blue: CGFloat(brush.blue),
                               alpha: CGFloat(brush.alpha))
        context.setLineWidth(CGFloat(brush.lineWidth))
        context.setLineCap(brush.lineCap)
        context.setBlendMode(brush.blendMode)
        context.addPath(bezierPath.cgPath)
        context.strokePath()
        
        context.restoreGState()
    }
    
    // MARK: - NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        guard let bezierPath = self.bezierPath.copy(with: zone) as? UIBezierPath,
            let brush = self.brush.copy(with: zone) as? Brush else
        {
            assertionFailure("Unsupported flow.")
            return Path(bezierPath: UIBezierPath(),
                        brush: Brush(red: 0, green: 0, blue: 0, alpha: 1, lineWidth: 3))
        }
        
        return Path(bezierPath: bezierPath, brush: brush)
    }
    
    // MARK: - NSCoding
    
    private enum Keys: String {
        case bezierPath
        case brush
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(NSKeyedArchiver.archivedData(withRootObject: bezierPath), forKey: Keys.bezierPath.rawValue)
        aCoder.encode(NSKeyedArchiver.archivedData(withRootObject: brush), forKey: Keys.brush.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let bezierPathData = aDecoder.decodeObject(forKey: Keys.bezierPath.rawValue) as? Data,
            let bezierPath = NSKeyedUnarchiver.unarchiveObject(with: bezierPathData) as? UIBezierPath,
            let brushData = aDecoder.decodeObject(forKey: Keys.brush.rawValue) as? Data,
            let brush = NSKeyedUnarchiver.unarchiveObject(with: brushData) as? Brush else
        {
            assertionFailure("Unsupported flow.")
            return nil
        }
        
        self.init(bezierPath: bezierPath, brush: brush)
    }
}
