//
//  AllNotesCollectionViewController.swift
//  ECE564project
//
//  Created by 杨越 on 11/3/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit
import PencilKit


class AllNotesCollectionViewController: UICollectionViewController, DataModelControllerObserver {
    
    var dataModelController = DataModelController()
    var drawingIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inform the data model of the current thumbnail traits.
        dataModelController.thumbnailTraitCollection = traitCollection
        
        // Observe changes to the data model.
        dataModelController.observers.append(self)
    }
    
    // Inform the data model of the current thumbnail traits
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        dataModelController.thumbnailTraitCollection = traitCollection
    }
    
    func dataModelChanged() {
        collectionView.reloadData()
    }
    
    // Create a new drawing.
    @IBAction func newDrawing(_ sender: Any) {
        dataModelController.newDrawing()
    }

    // MARK: Collection View Data Source
    
    // Number of sections
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Number of items in each section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModelController.drawings.count
    }
    
    // The view for each cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get a cell view with the correct identifier.
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NoteCell",
            for: indexPath) as? NoteCell
            else {
                fatalError("Unexpected cell type.")
        }
        
        // Set the thumbnail image, if available.
        if let index = indexPath.last, index < dataModelController.thumbnails.count {
            cell.noteImage.image = dataModelController.thumbnails[index]
        }
        
        return cell
    }
    
    // display the drawing for a cell that was tapped
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        drawingIndex = indexPath.last!
        performSegue(withIdentifier: "showNoteSegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showNoteSegue"){
            let navController = segue.destination as! DrawNaviController
            let dst = navController.topViewController as! NewDrawingViewController
            dst.dataModelController = self.dataModelController
            dst.drawingIndex = self.drawingIndex
        }
    }
    
    @IBAction func returnFromNote(segue: UIStoryboardSegue){
        
    }

}
