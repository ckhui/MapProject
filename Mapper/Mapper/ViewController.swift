//
//  ViewController.swift
//  Mapper
//
//  Created by NEXTAcademy on 11/21/16.
//  Copyright © 2016 ckhui. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    var nextAcademy : MKPointAnnotation!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.additional
        let latitude = 3.1349
        let longitude = 101.6299
        
        nextAcademy = MKPointAnnotation()
        nextAcademy.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        nextAcademy.title = "NextAcademy"
        
        mapView.addAnnotation(nextAcademy)
        
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let place = "KLCC"
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(place, completionHandler: { (placemarks, error) in
            if let placeM = placemarks{
                for place in placeM{
                    if let location = place.location{
                        print(place.name)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location.coordinate
                        annotation.title = place.name
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Home"
        if annotation.title! == "NextAcademy"
        {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){
                annotationView.annotation = annotation
                
                return annotationView
            }else{
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                annotationView.image = #imageLiteral(resourceName: "nextacademy")
                annotationView.canShowCallout = true
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return annotationView
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        mapView.setRegion(MKCoordinateRegionMake(nextAcademy.coordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
        
    }
    

}

