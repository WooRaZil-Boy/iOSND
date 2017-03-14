//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by 근성가이 on 2017. 3. 12..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    var coreDataStack: CoreDataStack!
    var selectedAnnotation: Annotation!
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapView()

        if let fetchDatas = performFetch(), fetchDatas.isEmpty {
            performFlickrFetch()
        }
    }
}

//MARK: - Actions
extension PhotoAlbumViewController {
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func refreshAction(_ sender: UIBarButtonItem) {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects  else {
            print("refreshAction_Error")
            let alertController = UIAlertController(title: "Refresh Error", message: "Please, Check your network condition and try again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        
            return
        }
        
        for object in fetchedObjects {
            coreDataStack.managedContext.delete(object)
        }
        
        performFlickrFetch()
    }
}

//MARK: - Methods
extension PhotoAlbumViewController {
    func performFetch() -> [Photos]? {
        let fetchRequest = NSFetchRequest<Photos>(entityName: Constants.CoreData.Photos)
        fetchRequest.predicate = NSPredicate(format: "annotation == %@", selectedAnnotation)
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("NSFetchRequest Error. \(error.localizedDescription)")
        }
        
        return fetchedResultsController.fetchedObjects
    }
    
    func performFlickrFetch() {
        FlickrClient.sharedInstance().flickrFetch(coordinate: selectedAnnotation.coordinate) { results, error in
            guard error == nil else {
                print("performFetch Error_\(error?.localizedDescription)")
                return
            }
            
            guard let resultsPhotos = results?[Constants.Flickr.ResponseKeys.Photos] as? [String: AnyObject],
                let photos = resultsPhotos[Constants.Flickr.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                    print("Parsing Error")
                    return
            }
        
            self.performUIUpdatesOnMain {
                for photoData in photos {
                    let photo = Photos(context: self.coreDataStack.managedContext)
                    photo.annotation = self.selectedAnnotation
                    photo.url = photoData[Constants.Flickr.ResponseKeys.MediumURL] as? String
                }
            
                self.coreDataStack.saveContext()
            }
        }
    }
    
    func setMapView() {
        mapView.addAnnotation(selectedAnnotation)
        mapView.camera.centerCoordinate = CLLocationCoordinate2DMake(selectedAnnotation.latitude, selectedAnnotation.longitude)
        mapView.camera.altitude = Constants.View.CameraAltitude
    }
}

//MARK: - UICollectionViewDelegate
extension PhotoAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coreDataStack.managedContext.delete(fetchedResultsController.object(at: indexPath))
        coreDataStack.saveContext()
    }
}

//MARK: - UICollectionViewDataSource
extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.View.PhotoAlbumCollectionViewCell, for: indexPath) as! PhotoAlbumCollectionViewCell
        
        cell.configure(photo)
        
        return cell
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}
