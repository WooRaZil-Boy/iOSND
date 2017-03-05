//
//  CollectionViewController.swift
//  MemeMe
//
//  Created by 근성가이 on 2017. 3. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class CollectionViewController: TabBarViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        coreDataStack = CoreDataStack(modelName: "Meme") //TODO: DI로 못 하나?
        performFetch()
    }
}

//MARK: - UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        editAction(indexPath: indexPath)
    }
}

//MARK: - UICollectionViewDataSource
extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
        let meme = fetchedResultsController.object(at: indexPath)
        cell.updateCell(meme)
        
        return cell
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension CollectionViewController {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}
