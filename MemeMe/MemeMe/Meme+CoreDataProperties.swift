//
//  Meme+CoreDataProperties.swift
//  MemeMe
//
//  Created by 근성가이 on 2017. 3. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData


extension Meme {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meme> {
        return NSFetchRequest<Meme>(entityName: "Meme");
    }

    @NSManaged public var bottomText: String?
    @NSManaged public var memedImage: NSData?
    @NSManaged public var originalImage: NSData?
    @NSManaged public var topText: String?
    @NSManaged public var regsterDate: NSDate?

}
