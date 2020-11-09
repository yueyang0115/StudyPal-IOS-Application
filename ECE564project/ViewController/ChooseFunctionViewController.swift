//
//  ChooseFunctionViewController.swift
//  ECE564project
//
//  Created by 杨越 on 11/7/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit

class ChooseFunctionViewController: UIViewController {

    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var noteIconView: UIImageView!
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var clockIconView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setAnimation(imageView: noteIconView, num: 197, name: "note", duration: 6)
        //setAnimation(imageView: clockIconView, num: 140, name: "clock", duration: 6)
        setAnimation(imageView: noteImageView, num: 40, name: "takingnote", duration: 4)
        setAnimation(imageView: clockImageView, num: 151, name: "study", duration: 15)
    }
    
    func setAnimation(imageView: UIImageView, num : Int, name: String, duration: Double){
        var images:[UIImage] = []
        for n in 0...num {
            images.append(UIImage(named: "\(name)_\(n)")!)
        }
        imageView.animationImages = images
        imageView.animationDuration = duration
        imageView.startAnimating()
        view?.addSubview(imageView)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func returnFromFunction(segue: UIStoryboardSegue){
        
    }
}
