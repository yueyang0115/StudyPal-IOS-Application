//
//  NoteCell.swift
//  ECE564project
//
//  Created by 杨越 on 11/3/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit

class NoteCell: UICollectionViewCell {
    
    @IBOutlet weak var noteImage: UIImageView!
    
    /// Set up the view initially.
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Give the view a shadow.
        noteImage.layer.shadowPath = UIBezierPath(rect: noteImage.bounds).cgPath
        noteImage.layer.shadowOpacity = 0.2
        noteImage.layer.shadowOffset = CGSize(width: 0, height: 3)
        noteImage.clipsToBounds = false
    }
    
}
