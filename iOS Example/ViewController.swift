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
    
    @IBOutlet weak var toolButton: UIBarButtonItem!
    @IBAction func toolButtonClicked(_ sender: UIBarButtonItem) {
        let sheet = UIAlertController(title: "Tool", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Pen", style: .default) { action in
            sender.title = action.title
            self.tool = .pen
        })
        
        sheet.addAction(UIAlertAction(title: "Eraser", style: .default) { action in
            sender.title = action.title
            self.tool = .eraser
        })
        
        sheet.addAction(UIAlertAction(title: "Line", style: .default) { action in
            sender.title = action.title
            self.tool = .line
        })
        
        if let popoverPresentationController = sheet.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender
        }
        
        present(sheet, animated: true)
    }
    var tool = DrawingTool.pen
    
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
        
        canvasView.setInitialImage(image)
    }
    
    var imagePath: String {
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                              .allDomainsMask,
                                                              true).first!
        return (documentDir as NSString).appendingPathComponent("image.png")
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
        
        center.addObserver(self,
                           selector: #selector(undoManagerDidCloseUndoGroup(notification:)),
                           name: .NSUndoManagerDidCloseUndoGroup,
                           object: canvasViewUndoManager)
    }
    
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notification Handler
    
    @objc func undoManagerDidUndoChange(notification: NSNotification) {
        print(">Undo change")
        undoButton.isEnabled = canvasViewUndoManager.canUndo
        redoButton.isEnabled = canvasViewUndoManager.canRedo
    }
    
    @objc func undoManagerDidRedoChange(notification: NSNotification) {
        print(">Redo change")
        undoButton.isEnabled = canvasViewUndoManager.canUndo
        redoButton.isEnabled = canvasViewUndoManager.canRedo
    }
    
    @objc func undoManagerDidCloseUndoGroup(notification: NSNotification) {
        print(">Undo Did close undo group")
        undoButton.isEnabled = canvasViewUndoManager.canUndo
        redoButton.isEnabled = canvasViewUndoManager.canRedo
    }
}

extension ViewController: CanvasViewDelegate {
    func tool(for canvasView: CanvasView) -> DrawingTool? {
        return tool
    }
    
    func brush(for canvasView: CanvasView) -> Brush? {
        return Brush(color: color, lineWidth: lineWidth)
    }
    
    func canvasView(_ canvasView: CanvasView, didUpdateDrawings drawings: [Drawable]) {
        print("Update drawings: \(drawings.count)")
        saveDrawings(drawings)
    }
    
    func canvasView(_ canvasView: CanvasView, didUpdateImage image: UIImage) {
        print("Update images: \(image)")
        saveImage(image)
    }
    
    func undoManager(for canvasView: CanvasView) -> UndoManager? {
        return canvasViewUndoManager
    }
}
