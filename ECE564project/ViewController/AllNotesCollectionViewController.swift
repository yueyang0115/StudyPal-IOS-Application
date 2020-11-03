//
//  AllNotesCollectionViewController.swift
//  ECE564project
//
//  Created by 杨越 on 11/3/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit
import PencilKit

private let reuseIdentifier = "Cell"

class AllNotesCollectionViewController: UICollectionViewController, DataModelControllerObserver {
    
    /// Data model for the drawings displayed by this view controller.
    var dataModelController = DataModelController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        // Inform the data model of the current thumbnail traits.
        dataModelController.thumbnailTraitCollection = traitCollection
        
        // Observe changes to the data model.
        dataModelController.observers.append(self)
    }
    
    /// Inform the data model of the current thumbnail traits.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        dataModelController.thumbnailTraitCollection = traitCollection
    }
    
    // MARK: Data Model Observer
    
    func dataModelChanged() {
        collectionView.reloadData()
    }
    
    // MARK: Actions
    
    /// Action method: Create a new drawing.
    @IBAction func newDrawing(_ sender: Any) {
        dataModelController.newDrawing()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Collection View Data Source
    
    /// Data source method: Number of sections.
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //return 0
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModelController.drawings.count
    }

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
    
    // MARK: Collection View Delegate
    
    /// Delegate method: Display the drawing for a cell that was tapped.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Create the drawing.
        guard let drawingViewController = storyboard?.instantiateViewController(withIdentifier: "NewDrawingViewController") as? NewDrawingViewController,
            let navigationController = navigationController else {
                return
        }
        
        // Transition to the drawing view controller.
        drawingViewController.dataModelController = dataModelController
        drawingViewController.drawingIndex = indexPath.last!
        navigationController.pushViewController(drawingViewController, animated: true)
        performSegue(withIdentifier: "showNoteSegue", sender: self)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    @IBAction func returnFromNote(segue: UIStoryboardSegue){
        
    }

}
