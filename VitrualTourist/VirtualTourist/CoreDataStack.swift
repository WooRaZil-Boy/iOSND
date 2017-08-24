//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by 근성가이 on 2017. 3. 13..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData

//TODO: - Thread-Safety Check
class CoreDataStack {
    private let modelName: String

    init (modelName: String) {
        self.modelName = modelName
    }
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()

    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("storeContainer error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else {
            return
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("saveContext error \(error), \(error.userInfo)")
        }
    }
}
