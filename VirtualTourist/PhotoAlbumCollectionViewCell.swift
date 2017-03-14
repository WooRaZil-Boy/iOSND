//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by 근성가이 on 2017. 3. 13..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
}

//MARK: - Methods
extension PhotoAlbumCollectionViewCell { //TODO: - Reuse Check
    func configure(_ photo: Photos) {
        if let image = photo.image {
            photoView.image = UIImage(data: image as Data)
        } else {
            guard let url = photo.url else {
                print("URL is nil")
                return
            }
            
            spinner.startAnimating()
            FlickrClient.sharedInstance().downloadPhoto(url: URL(string: url)!) { image, error in
                guard error == nil else {
                    print("configure Error")
                    return
                }
    
                photo.image = image
                self.spinner.stopAnimating()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoView.image = nil
    }
}
