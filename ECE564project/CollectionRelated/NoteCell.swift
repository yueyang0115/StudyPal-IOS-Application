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
    
    // set a note's preview in collection view
    override func awakeFromNib() {
        super.awakeFromNib()
        noteImage.layer.shadowPath = UIBezierPath(rect: noteImage.bounds).cgPath
        noteImage.layer.shadowOpacity = 0.3
        noteImage.layer.shadowOffset = CGSize(width: 0, height: 2)
        noteImage.clipsToBounds = false
    }
    
}
