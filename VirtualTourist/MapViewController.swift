//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by 근성가이 on 2017. 3. 12..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    var coreDataStack: CoreDataStack!

    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performFetch()
    }
}

//MARK: - Methods
extension MapViewController {
    func performFetch() {
        let fetchRequest = NSFetchRequest<Annotation>(entityName: Constants.CoreData.Annotaion)
        
        do {
            let annotations = try coreDataStack.managedContext.fetch(fetchRequest)
            mapView.addAnnotations(annotations)
        } catch let error as NSError {
            print("NSFetchRequest Error. \(error.localizedDescription)")
        }
    }
}

//MARK: - Navigations
extension MapViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.Segue.PhotoAlbum, let navigationController = segue.destination as? UINavigationController,
                let photoalbumViewController = navigationController.topViewController as? PhotoAlbumViewController,
                let annotation = sender as? Annotation else {
                    print("prepare_Error")
            return
        }
        
        photoalbumViewController.coreDataStack = coreDataStack
        photoalbumViewController.selectedAnnotation = annotation
    }
}

//MARK: - UIGestureRecognizerDelegate
extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is UILongPressGestureRecognizer else {
            print("gestureRecognizerShouldBegin_Error")
            return false
        }
        
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = Annotation(context: coreDataStack.managedContext)
        annotation.latitude = coordinate.latitude
        annotation.longitude = coordinate.longitude
        mapView.addAnnotation(annotation)
        
        coreDataStack.saveContext()
        
        return true
    }
}

//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        mapView.selectAnnotation(annotation!, animated: false)
        performSegue(withIdentifier: "PhotoAlbumSegue", sender: annotation)
        mapView.deselectAnnotation(annotation, animated: true)
    }
}
