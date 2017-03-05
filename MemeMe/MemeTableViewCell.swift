//
//  MemeTableViewCell.swift
//  MemeMe
//
//  Created by 근성가이 on 2017. 3. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class MemeTableViewCell: UITableViewCell {
    //MARK: -Properties
    @IBOutlet weak var memedImageView: UIImageView!
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var bottonTextLabel: UILabel!
    
    func updateCell(_ meme:Meme) {
        memedImageView.image = UIImage(data: meme.memedImage as! Data)
        topTextLabel.text = meme.topText
        bottonTextLabel.text = meme.bottomText
    }
}
