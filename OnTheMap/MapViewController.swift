//
//  MapViewController.swift
//  OnTheMap
//
//  Created by 근성가이 on 2017. 3. 9..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: OnTheMapViewController {
    //MARK: - Properties
    var selectedLocation: String!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARKL - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkClient.sharedInstance().getStudentLocations() { success, errorString, locations in
            guard success == true else {
                print("viewDidLoad_\(errorString)")
                return
            }
            
            self.refreshAction(locations!)
        }
    }
}

//MARL: - OnTheMapViewController
extension MapViewController {
    override func refreshAction(_ locations: [Location]) {
        performUIUpdatesOnMain {
            self.mapView.addAnnotations(locations)
        }
    }
}

//MARK: - Actions
extension MapViewController {
    func showMedia() {
        openURL(selectedLocation)
    }
}

//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else {
            return nil
        }
        
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
        } else {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            
            let rightButton = UIButton(type: .detailDisclosure) //annotation에 버튼 추가
            rightButton.addTarget(self, action: #selector(showMedia), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            
            annotationView = pinView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let location = view.annotation as? Location else {
            return
        }
        
        selectedLocation = location.mediaURL
    }
}
