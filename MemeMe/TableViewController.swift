//
//  TableViewController.swift
//  MemeMe
//
//  Created by 근성가이 on 2017. 3. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: TabBarViewController {
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performFetch()
        navigationItem.leftBarButtonItem = editButtonItem
    }
}

//MARK - Methods
extension TableViewController {
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
}

//MARK: - UITableViewDelegate
extension TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editAction(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let meme = fetchedResultsController.object(at: indexPath)
        
        switch editingStyle {
        case .delete:
            coreDataStack.managedContext.delete(meme)
        default:
            break
        }
    }
}

//MARK - UITableViewDataSource
extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableViewCell", for: indexPath) as! MemeTableViewCell
        let meme = fetchedResultsController.object(at: indexPath)
        cell.updateCell(meme)
        
        return cell
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TableViewController {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
        
        coreDataStack.saveContext()
    }
}
