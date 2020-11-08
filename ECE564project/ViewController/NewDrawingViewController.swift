//
//  NewDrawingViewController.swift
//  ECE564project
//
//  Created by 杨越 on 10/27/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit
import PencilKit
import PhotosUI

class NewDrawingViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver, UIScreenshotServiceDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var pencilButton: UIBarButtonItem!
    
    var toolPicker: PKToolPicker!
    
    let canvasWidth: CGFloat = 768
    let canvasHeight:CGFloat = 500
    
    var dataModelController: DataModelController!
    var drawingIndex: Int = 0
    var hasModifiedDrawing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setCanvas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCanvas()
        parent?.view.window?.windowScene?.screenshotService?.delegate = self
    }
    
    func setCanvas(){
        canvasView.delegate = self
        canvasView.drawing = dataModelController.drawings[drawingIndex]
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = false
        
        let window = parent?.view.window
        toolPicker = PKToolPicker.shared(for: window!)
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            toolPicker.addObserver(self)
            updateLayout(for: toolPicker)
            canvasView.becomeFirstResponder()
        
    }

    @IBAction func saveImageToAlbum(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if image != nil {
//            PHPhotoLibrary.shared().performChanges(
//                {PHAssetChangeRequest.creationRequestForAsset(from: image!)},
//                completionHandler: {success, error in })
            let activityController = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
//            activityController.completionWithItemsHandler = { (nil, completed, _, error) in
//                if completed{
//                    print("completed")
//                }
//                else{
//                    print("cancled")
//                }
//            }
            present(activityController, animated: true)
//            {
//                print("presented")
//            }
        }
    }
    
    @IBAction func changePencilFinger(_ sender: Any) {
        canvasView.allowsFingerDrawing.toggle()
        pencilButton.title = canvasView.allowsFingerDrawing ? "toFinger" : "toPencil"
    }
    
    // - MARK: make view rotation work
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let canvasScale = canvasView.bounds.width / self.canvasWidth
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
        hasModifiedDrawing = true
        updateContentSize()
    }
    func updateContentSize() {
        // Update the content size to match the drawing.
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        
        // Adjust the content size to always be bigger than the drawing height.
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasHeight) * canvasView.zoomScale)
        } else {
            contentHeight = canvasView.bounds.height
        }
        canvasView.contentSize = CGSize(width: DataModel.canvasWidth * canvasView.zoomScale, height: contentHeight)
    }

    
//    func updateContentSize(){
//        let drawing = canvasView.drawing
//        let contentHeight: CGFloat
//        if !drawing.bounds.isNull{
//            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasHeight) * canvasView.zoomScale)
//            }
//        else{
//            contentHeight = canvasView.bounds.height
//        }
//        canvasView.contentSize = CGSize(width: self.canvasWidth * canvasView.zoomScale, height: contentHeight)
//    }
    
    // When the view is removed, save the modified drawing
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if hasModifiedDrawing {
            dataModelController.updateDrawing(canvasView.drawing, at: drawingIndex)
        }
        view.window?.windowScene?.screenshotService?.delegate = nil
    }
    
    // MARK: Tool Picker Observer
    
    // toolpicker has changed and obscures
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
    
    // toolpicker become visible or hidden
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }

    // adjust canvesView size when tool picker change
    func updateLayout(for toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: view)
        
        // If the tool picker is floating over the canvas, it also contains
        // undo and redo buttons.
        if obscuredFrame.isNull {
            canvasView.contentInset = .zero
        }
        
        // Otherwise, the bottom of the canvas should be inset to the top of the
        // tool picker, and the tool picker no longer displays its own undo and
        // redo buttons.
        else {
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.bounds.maxY - obscuredFrame.minY, right: 0)
        }
        canvasView.scrollIndicatorInsets = canvasView.contentInset
    }
    
    // MARK: Screenshot Service Delegate
    // generate a screenshot of pdf
    func screenshotService(
        _ screenshotService: UIScreenshotService,
        generatePDFRepresentationWithCompletion completion:
        @escaping (_ PDFData: Data?, _ indexOfCurrentPage: Int, _ rectInCurrentPage: CGRect) -> Void) {
        
        // Find out which part of the drawing is actually visible.
        let drawing = canvasView.drawing
        let visibleRect = canvasView.bounds
        
        // Convert to PDF coordinates, with (0, 0) at the bottom left hand corner,
        // making the height a bit bigger than the current drawing.
        let pdfWidth = self.canvasWidth
        let pdfHeight = drawing.bounds.maxY + 100
        let canvasContentSize = canvasView.contentSize.height - self.canvasHeight
        
        let xOffsetInPDF = pdfWidth - (pdfWidth * visibleRect.minX / canvasView.contentSize.width)
        let yOffsetInPDF = pdfHeight - (pdfHeight * visibleRect.maxY / canvasContentSize)
        let rectWidthInPDF = pdfWidth * visibleRect.width / canvasView.contentSize.width
        let rectHeightInPDF = pdfHeight * visibleRect.height / canvasContentSize
        
        let visibleRectInPDF = CGRect(
            x: xOffsetInPDF,
            y: yOffsetInPDF,
            width: rectWidthInPDF,
            height: rectHeightInPDF)
        
        // Generate the PDF on a background thread.
        DispatchQueue.global(qos: .background).async {
            
            // Generate a PDF.
            let bounds = CGRect(x: 0, y: 0, width: pdfWidth, height: pdfHeight)
            let mutableData = NSMutableData()
            UIGraphicsBeginPDFContextToData(mutableData, bounds, nil)
            UIGraphicsBeginPDFPage()
            
            // Generate images in the PDF, strip by strip.
            var yOrigin: CGFloat = 0
            let imageHeight: CGFloat = 1024
            while yOrigin < bounds.maxY {
                let imgBounds = CGRect(x: 0, y: yOrigin, width: self.canvasWidth, height: min(imageHeight, bounds.maxY - yOrigin))
                let img = drawing.image(from: imgBounds, scale: 2)
                img.draw(in: imgBounds)
                yOrigin += imageHeight
            }
            
            UIGraphicsEndPDFContext()
            
            // Invoke the completion handler with the generated PDF data.
            completion(mutableData as Data, 0, visibleRectInPDF)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            let popoverVc = segue.destination
            popoverVc.modalPresentationStyle = .popover
            popoverVc.popoverPresentationController?.delegate = self;
            popoverVc.preferredContentSize = CGSize(width: 250, height: 250)
        }
    }

}
