//
//  ViewController.swift
//  iOS Example
//
//  Created by Yu Sugawara on 3/13/17.
//  Copyright © 2017 Yu Sugawara. All rights reserved.
//

import UIKit
import DrawingCanvas

class ViewController: UIViewController {
    
    let canvasViewUndoManager = UndoManager()
    
    @IBOutlet weak var toolControl: UISegmentedControl!
    
    @IBOutlet weak var widthControl: UISegmentedControl!
    
    var lineWidth: Double {
        switch widthControl.selectedSegmentIndex {
        case 0:
            return 3
        case 1:
            return 10
        default:
            fatalError()
        }
    }
    
    @IBOutlet weak var colorControl: UISegmentedControl!
    
    var color: UIColor {
        switch colorControl.selectedSegmentIndex {
        case 0:
            return .black
        case 1:
            return .red
        default:
            fatalError()
        }
    }
    
    @IBOutlet weak var canvasView: CanvasView! {
        didSet {
            canvasView.delegate = self
        }
    }
    
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        registerNotifications()
    }
    
    deinit {
        unregisterNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let canRestoreDrawings = self.canRestoreDrawings
        let canRestoreImage = self.canRestoreImage
        
        if canRestoreDrawings || canRestoreImage {
            let alert = UIAlertController(title: "Restore", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            if canRestoreDrawings {
                alert.addAction(UIAlertAction(title: "Drawings", style: .default, handler: { (action: UIAlertAction) in
                    self.restoreDrawings()
                }))
            }
            
            if canRestoreImage {
                alert.addAction(UIAlertAction(title: "Image", style: .default, handler: { (action: UIAlertAction) in
                    self.restoreImage()
                }))
            }
            
            present(alert, animated: true)
        }
    }
    
    // MARK: -
    
    @IBAction func undo() {
        canvasViewUndoManager.undo()
    }
    
    @IBAction func redo() {
        canvasViewUndoManager.redo()
    }
    
    @IBAction func clear() {
        canvasView.clear()
    }
    
    // MARK: -
    
    func saveDrawings(_ drawings: [Drawable]) {
        if drawings.count > 0 {
            saveData(NSKeyedArchiver.archivedData(withRootObject: drawings),
                     atPath: drawingsPath)
        } else {
            removeData(atPath: drawingsPath)
        }
    }
    
    var canRestoreDrawings: Bool {
        return FileManager.default.fileExists(atPath: drawingsPath)
    }
    
    func restoreDrawings() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: drawingsPath)),
            let drawings = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Drawable] else
        {
            fatalError()
        }
        
        canvasView.setDrawings(drawings)
    }
    
    var drawingsPath: String {
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                              .allDomainsMask,
                                                              true).first!
        return (documentDir as NSString).appendingPathComponent("drawings")
    }
    
    // MARK: -
    
    func saveImage(_ image: UIImage?) {
        guard let image = image else {
            removeData(atPath: imagePath)
            return
        }
        
        guard let data = UIImagePNGRepresentation(image) else {
            fatalError()
        }
        
        saveData(data, atPath: imagePath)
    }
    
    var canRestoreImage: Bool {
        return FileManager.default.fileExists(atPath: imagePath)
    }
    
    func restoreImage() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: imagePath)),
            let image = UIImage(data: data, scale: UIScreen.main.scale) else
        {
            fatalError()
        }
        
        canvasView.setImage(image)
    }
    
    var imagePath: String {
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                              .allDomainsMask,
                                                              true).first!
        return (documentDir as NSString).appendingPathComponent("image.jpg")
    }
    
    // MARK: - 
    
    func saveData(_ data: Data, atPath path: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try! fileManager.removeItem(atPath: path)
        }
        
        try! data.write(to: URL(fileURLWithPath: path))
    }
    
    func removeData(atPath path: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try! fileManager.removeItem(atPath: path)
        }
    }
    
    // MARK: - Notification
    
    func registerNotifications() {
        let center = NotificationCenter.default
        
        center.addObserver(self,
                           selector: #selector(undoManagerDidUndoChange(notification:)),
                           name: .NSUndoManagerDidUndoChange,
                           object: canvasViewUndoManager)
        
        center.addObserver(self,
                           selector: #selector(undoManagerDidRedoChange(notification:)),
                           name: .NSUndoManagerDidRedoChange,
                           object: canvasViewUndoManager)
    }
    
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notification Handler
    
    func undoManagerDidUndoChange(notification: NSNotification) {
        print("Undo change")
        undoButton.isEnabled = canvasViewUndoManager.canUndo
    }
    
    func undoManagerDidRedoChange(notification: NSNotification) {
        print("Redo change")
        redoButton.isEnabled = canvasViewUndoManager.canRedo
    }
}

extension ViewController: CanvasViewDelegate {
    func brush(for canvasView: CanvasView) -> Brush? {
        switch toolControl.selectedSegmentIndex {
        case 0:
            return Brush(color: color, lineWidth: lineWidth)
        case 1:
            return Brush.eraser(lineWidth: lineWidth)
        default:
            fatalError()
        }
    }
    
    func canvasView(_ canvasView: CanvasView, didUpdateDrawings drawings: [Drawable]) {
        print("Update drawings: \(drawings.count)")
        undoButton.isEnabled = canvasViewUndoManager.canUndo
        redoButton.isEnabled = canvasViewUndoManager.canRedo
        saveDrawings(drawings)
    }
    
    func canvasView(_ canvasView: CanvasView, didUpdateImage image: UIImage?) {
        print("Update images: \(image)")
        saveImage(image)
    }
    
    func undoManager(for canvasView: CanvasView) -> UndoManager? {
        return canvasViewUndoManager
    }
}
