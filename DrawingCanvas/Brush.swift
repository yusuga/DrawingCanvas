//
//  Brush.swift
//  DrawingCanvas
//
//  Created by Yu Sugawara on 3/13/17.
//  Copyright © 2017 Yu Sugawara. All rights reserved.
//

import Foundation

public class Brush: NSObject, NSCopying, NSCoding {
    
    // MARK: - Properties
    
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double
    
    public let lineWidth: Double
    public let lineCap: CGLineCap
    
    public let blendMode: CGBlendMode
    
    public var isSmoothDrawing = true
    
    // MARK: - Initializers
    
    public convenience init(color: UIColor = .black,
                            lineWidth: Double = 5,
                            lineCap: CGLineCap = .round,
                            blendMode: CGBlendMode = .normal)
    {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1
        
        if !color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            if color.getWhite(&red, alpha: &alpha) {
                green = red
                blue = red
            } else {
                assertionFailure("Unsupported flow.")
            }
        }
        
        self.init(red: Double(red),
                  green: Double(green),
                  blue: Double(blue),
                  alpha: Double(alpha),
                  lineWidth: lineWidth,
                  blendMode: blendMode)
    }
    
    public init(red: Double,
                green: Double,
                blue: Double,
                alpha: Double,
                lineWidth: Double,
                lineCap: CGLineCap = .round,
                blendMode: CGBlendMode = .normal)
    {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        
        self.lineWidth = lineWidth
        self.lineCap = lineCap
        
        self.blendMode = blendMode
    }
    
    public class func eraser(lineWidth: Double = 5,
                             lineCap: CGLineCap = .round) -> Brush
    {
        return Brush(lineWidth: lineWidth,
                     lineCap: lineCap,
                     blendMode: .clear)
    }
    
    // MARK: Equatable
    
    static func ==(lhs: Brush, rhs: Brush) -> Bool {
        return lhs.red == rhs.red
            && lhs.green == rhs.green
            && lhs.blue == rhs.blue
            && lhs.alpha == rhs.alpha
            
            && lhs.lineWidth == rhs.lineWidth
            && lhs.lineCap == rhs.lineCap
            
            && lhs.blendMode == rhs.blendMode
    }    
    
    // MARK: - NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return Brush(red: red,
                     green: green,
                     blue: blue,
                     alpha: alpha,
                     lineWidth: lineWidth,
                     lineCap: lineCap,
                     blendMode: blendMode)
    }
    
    // MARK: - NSCoding
    
    private enum Keys: String {
        case red, green, blue, alpha
        case lineWidth, lineCap
        case blendMode
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(red, forKey: Keys.red.rawValue)
        aCoder.encode(green, forKey: Keys.green.rawValue)
        aCoder.encode(blue, forKey: Keys.blue.rawValue)
        aCoder.encode(alpha, forKey: Keys.alpha.rawValue)
        
        aCoder.encode(lineWidth, forKey: Keys.lineWidth.rawValue)
        aCoder.encode(lineCap.rawValue, forKey: Keys.lineCap.rawValue)
        
        aCoder.encode(blendMode.rawValue, forKey: Keys.blendMode.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let lineCap = CGLineCap(rawValue: aDecoder.decodeInt32(forKey: Keys.lineCap.rawValue)),
            let blendMode = CGBlendMode(rawValue: aDecoder.decodeInt32(forKey: Keys.blendMode.rawValue)) else
        {
            assertionFailure("Unsupported flow.")
            return nil
        }
        
        self.init(red: aDecoder.decodeDouble(forKey: Keys.red.rawValue),
                  green: aDecoder.decodeDouble(forKey: Keys.green.rawValue),
                  blue: aDecoder.decodeDouble(forKey: Keys.blue.rawValue),
                  alpha: aDecoder.decodeDouble(forKey: Keys.alpha.rawValue),
                  lineWidth: aDecoder.decodeDouble(forKey: Keys.lineWidth.rawValue),
                  lineCap: lineCap,
                  blendMode: blendMode)
    }
}
