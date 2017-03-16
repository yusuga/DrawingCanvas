//
//  CanvasView.swift
//  DrawingCanvas
//
//  Created by Yu Sugawara on 3/13/17.
//  Copyright © 2017 Yu Sugawara. All rights reserved.
//

import Foundation

public class CanvasView: UIView {
    
    // MARK: - Properties
    
    public var delegate: CanvasViewDelegate?
    
    private var currentDrawingPath: DrawablePath?
    private var drawings = [Drawable]() {
        didSet {
            drawingsImage = nil
            needsUpdateImage = true
        }
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return imageView
    }()
    private var drawingsImage: UIImage?
    private var needsUpdateImage = false {
        didSet {
            if needsUpdateImage {
                setNeedsDisplay()
            }
        }
    }
    
    // MARK: - Drawing
    
    public func setImage(_ image: UIImage) {
        appendDrawing(DrawingImage(image: image))
    }
    
    public func clear() {
        setDrawings([])
    }
    
    public func setDrawings(_ drawings: [Drawable]) {
        let undoManager = delegate?.undoManager(for: self)
        
        if drawings.count > 0 {
            let groupsByEvent = undoManager?.groupsByEvent
            undoManager?.groupsByEvent = false
            
            for drawing in drawings {
                undoManager?.beginUndoGrouping()
                self.appendDrawing(drawing)
                undoManager?.endUndoGrouping()
            }
            
            if let groupsByEvent = groupsByEvent {
                undoManager?.groupsByEvent = groupsByEvent
            }
        } else {
            if let undoManager = undoManager {
                let drawings = self.drawings
                undoManager.registerUndo(withTarget: self) { canvasView in
                    drawings.forEach { canvasView.appendDrawing($0) }
                }
            }
            
            self.drawings = drawings
        }
    }
    
    private func appendDrawing(_ drawing: Drawable) {
        drawings.append(drawing)
        
        if let undoManager = delegate?.undoManager(for: self) {
            undoManager.registerUndo(withTarget: self) { canvasView in
                canvasView.popDrawing()
            }
        }
    }
    
    private func popDrawing() {
        if let drawing = drawings.popLast(),
            let undoManager = delegate?.undoManager(for: self)
        {
            undoManager.registerUndo(withTarget: self) { canvasView in
                canvasView.appendDrawing(drawing)
            }
        }
    }
    
    // MARK: - Layouts
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageView.superview == nil {
            addSubview(imageView)
            imageView.frame = bounds
        }
    }
    
    // MARK: - Responding to Touch Events
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let tool = delegate?.tool(for: self),
            let brush = delegate?.brush(for: self),
            let touch = touches.first
        {
            currentDrawingPath = tool.drawingPath(startPoint: touch.location(in: self),
                                                  brush: brush)
            needsUpdateImage = true
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentDrawingPath = currentDrawingPath,
            let touch = touches.first
        {
            currentDrawingPath.addPoint(touch.location(in: self))
            needsUpdateImage = true
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentDrawingPath = currentDrawingPath {
            self.currentDrawingPath = nil
            appendDrawing(currentDrawingPath)
        }
    }
    
    // MARK: - Draw
    
    open override func draw(_ rect: CGRect) {
        if !needsUpdateImage {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        if let context = UIGraphicsGetCurrentContext() {
            if let drawingsImage = drawingsImage {
                drawingsImage.draw(at: CGPoint.zero)
            } else {
                drawings.forEach { $0.draw(in: context) }
                drawingsImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            
            currentDrawingPath?.draw(in: context)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if let image = image {
            imageView.image = image
            
            if currentDrawingPath == nil {
                drawingsImage = image
                delegate?.canvasView(self, didUpdateDrawings: drawings)
                delegate?.canvasView(self, didUpdateImage: image)
            }
        }
    }
}
