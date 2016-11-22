//
//  ViewController.swift
//  burgerGPS
//
//  Created by NEXTAcademy on 11/22/16.
//  Copyright © 2016 ckhui. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    @IBAction func buttonPressed(_ sender: AnyObject) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        self.textView.text = "Finding your location ....."
    }
    func reverserGeocode(location : CLLocation){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, errors) in
            if let placemarks = placemarks{
                if let placemark = placemarks.first {
                    var address = ""
                    if let thoroughfare = placemark.thoroughfare,
                        let locality = placemark.locality {
                        address = "\(thoroughfare),\(locality)"
                        
                        let text = "\(self.textView.text!) \n \(address)"
                        self.textView.text = text
                        
                        self.findBurger(location: location)
                    }
                }
            }
            
        })
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            if location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000 {
                print("trying")
                locationManager.stopUpdatingLocation()
                let text = "\(textView.text!) \n Found you!"
                textView.text = text
                
                self.reverserGeocode(location: location)
            }
        }
    }
    
    func findBurger(location : CLLocation){
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "Burgers"
        request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.5, 0.5))
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: { (response,error) in
            if let response = response{
                //let mapItem = response.mapItems.first
                for mapItem in response.mapItems{
                let text = "\(self.textView.text!) \n \(mapItem.name!)"
                self.textView.text = text
                self.findRoute(mapItem: mapItem)
                }
                
            }
        })
        
    }
    
    func findRoute(mapItem : MKMapItem){
        let request = MKDirectionsRequest()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapItem
        request.transportType = MKDirectionsTransportType.automobile
        
        let direction = MKDirections(request: request)
        direction.calculate(completionHandler: {(response, error) in
            if let response = response {
                if let route = response.routes.first {
                    if let name = mapItem.name {
                        self.textView.text = "\(self.textView.text!) \n Going to \(name)"
                    }
                    for (index,steps) in route.steps.enumerated(){
                        self.textView.text = "\(self.textView.text!) \n \(index+1). \(steps.instructions)"
                        
                    }
                }
            }
        })
    }
    
}

