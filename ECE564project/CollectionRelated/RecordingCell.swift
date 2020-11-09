//
//  RecordingCell.swift
//  ECE564project
//
//  Created by 杨越 on 11/8/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import Foundation
import UIKit

class RecordingCell: UITableViewCell {
    
    @IBOutlet weak var cell_image: UIImageView!
    @IBOutlet weak var cell_name: UILabel!
    
    func setCell(name: String){
        //self.cell_image.image =  UIImage(named: "aduio6")
        self.cell_name.text = "\(name)"
    }
}
