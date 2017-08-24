//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by 근성가이 on 2017. 3. 5..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var memedImageView: UIImageView!
    var meme: Meme!
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memedImageView.image = UIImage(data: meme.memedImage as! Data)
    }
}
