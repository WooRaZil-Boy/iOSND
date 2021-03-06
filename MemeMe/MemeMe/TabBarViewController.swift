//
//  TabBarViewController.swift
//  MemeMe
//
//  Created by 근성가이 on 2017. 3. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class TabBarViewController: UIViewController, NSFetchedResultsControllerDelegate {
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<Meme>!
}

//MARK: - Method
extension TabBarViewController {    
    func performFetch() {
        let fetchRequest: NSFetchRequest<Meme> = Meme.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Meme.regsterDate), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        //TODO: Cache
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    func editAction(indexPath: IndexPath) {
        let meme = fetchedResultsController.object(at: indexPath)
        performSegue(withIdentifier: "DetailMode", sender: meme)
    }
}

//MARK: - Navigations
extension TabBarViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailMode", let meme = sender as? Meme {
            let memeDetailViewController = segue.destination as! MemeDetailViewController
            memeDetailViewController.meme = meme
        } else {
            let memeEditorViewController = segue.destination as! MemeEditorViewController
            memeEditorViewController.coreDataStack = coreDataStack
            memeEditorViewController.parentTabBarViewController = self
        }
    }
}
