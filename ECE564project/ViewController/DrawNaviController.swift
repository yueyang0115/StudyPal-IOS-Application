//
//  DrawNaviController.swift
//  ECE564project
//
//  Created by 杨越 on 11/7/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit

class DrawNaviController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated);
        
    }

    // MARK: - Navigation
    // preparation, pass information of the chosen person to BackViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    @IBAction func returnFromBackView(segue: UIStoryboardSegue){
    }
}

