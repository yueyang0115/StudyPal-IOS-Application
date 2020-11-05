//
//  DataModel.swift
//  ECE564project
//
//  Created by 杨越 on 11/3/20.
//  Copyright © 2020 杨越. All rights reserved.
//

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's data model for storing drawings, thumbnails, and signatures.
*/

/// Underlying the app's data model is a cross-platform `PKDrawing` object. `PKDrawing` adheres to `Codable`
/// in Swift, or you can fetch its data representation as a `Data` object through its `dataRepresentation()`
/// method. `PKDrawing` is the only PencilKit type supported on non-iOS platforms.

/// From `PKDrawing`'s `image(from:scale:)` method, you can get an image to save, or you can transform a
/// `PKDrawing` and append it to another drawing.

/// If you already have some saved `PKDrawing`s, you can make them available in this sample app by adding them
/// to the project's "Assets" catalog, and adding their asset names to the `defaultDrawingNames` array below.

import UIKit
import PencilKit
import os

/// `DataModel` contains the drawings that make up the data model, including multiple image drawings and a signature drawing.
struct DataModel: Codable {
    
    /// Names of the drawing assets to be used to initialize the data model the first time.
    static let defaultDrawingNames: [String] = ["Notes"]
    
    /// The width used for drawing canvases.
    static let canvasWidth: CGFloat = 680
    
    /// The drawings that make up the current data model.
    var drawings: [PKDrawing] = []
    var signature = PKDrawing()
}

