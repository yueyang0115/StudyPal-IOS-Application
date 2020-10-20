//
//  ViewController.swift
//  ECE564project
//
//  Created by 杨越 on 10/19/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

    @IBOutlet weak var pencilButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var canvasView: PKCanvasView!
    
    let canvasWidth: CGFloat = 768
    let canvasHeight:CGFloat = 500
    var drawing = PKDrawing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCanvas()
    }
    
    func setCanvas(){
        canvasView.delegate = self
        canvasView.drawing = drawing
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        
        if let window = parent?.view.window,
        let toolPicker = PKToolPicker.shared(for: window){
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
    }

    @IBAction func saveImageToAlbum(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if image != nil {
            PHPhotoLibrary.shared().performChanges(
                {PHAssetChangeRequest.creationRequestForAsset(from: image!)},
                completionHandler: {success, error in })
        }
    }
    
    @IBAction func changePencilFinger(_ sender: Any){
        canvasView.allowsFingerDrawing.toggle()
        pencilButton.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
    }
    
    // - MARK: make view rotation work
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        updateContentSize()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSize()
    }
    
    func updateContentSize(){
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        if !drawing.bounds.isNull{
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasHeight) * canvasView.zoomScale)
        }
        else{
            contentHeight = canvasView.bounds.height
        }
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHeight)
    }
}

