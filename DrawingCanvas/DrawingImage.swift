//
//  DrawingImage.swift
//  DrawingCanvas
//
//  Created by Yu Sugawara on 3/14/17.
//  Copyright © 2017 Yu Sugawara. All rights reserved.
//

import Foundation

public class DrawingImage: NSObject, Drawable {
    
    // MARK: - Properties
    
    public let image: UIImage
    
    // MARK: - Initializers
    
    public init(image: UIImage) {
        self.image = image
        super.init()
    }
    
    // MARK: - Drawable
    
    public func draw(in context: CGContext) {
        image.draw(at: CGPoint.zero)
    }
    
    // MARK: - NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        if let cgImage = image.cgImage {
            return DrawingImage(image: UIImage(cgImage: cgImage,
                                               scale: image.scale,
                                               orientation: image.imageOrientation))
        }
        if let ciImage = image.ciImage {
            return DrawingImage(image: UIImage(ciImage: ciImage,
                                               scale: image.scale,
                                               orientation: image.imageOrientation))
        }
        
        assertionFailure("Unsupported flow.")
        return DrawingImage(image: UIImage())
    }
    
    // MARK: - NSCoding
    
    private enum Keys: String {
        case image
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(UIImagePNGRepresentation(image), forKey: Keys.image.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let data = aDecoder.decodeObject(forKey: Keys.image.rawValue) as? Data,
            let image = UIImage(data: data, scale: UIScreen.main.scale) else
        {
            assertionFailure("Unsupported flow.")
            return nil
        }
        
        self.init(image: image)
    }

}
