//
//  CanvasViewDelegate.swift
//  DrawingCanvas
//
//  Created by Yu Sugawara on 3/13/17.
//  Copyright © 2017 Yu Sugawara. All rights reserved.
//

import Foundation

public protocol CanvasViewDelegate {
    func canvasView(_ canvasView: CanvasView, didUpdateDrawings drawings: [Drawable])
    func canvasView(_ canvasView: CanvasView, didUpdateImage image: UIImage)
    func undoManager(for canvasView: CanvasView) -> UndoManager?
}

public extension CanvasViewDelegate {
    func canvasView(_ canvasView: CanvasView, didUpdateDrawings drawings: [Drawable]) { }
    func canvasView(_ canvasView: CanvasView, didUpdateImage image: UIImage) { }
    func undoManager(for canvasView: CanvasView) -> UndoManager? { return nil }
}
