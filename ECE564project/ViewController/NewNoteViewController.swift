//
//  NewNoteViewController.swift
//  ECE564project
//
//  Created by 杨越 on 10/27/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit

class NewNoteViewController: UIViewController {

    @IBOutlet weak var painterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

//    @IBAction func drawImage(_ sender: Any) {
//        performSegue(withIdentifier: "createNewDrawing", sender: self)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func returnFromNewDrawing(segue: UIStoryboardSegue){
    
    }
}
