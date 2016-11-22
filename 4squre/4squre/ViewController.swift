//
//  ViewController.swift
//  4squre
//
//  Created by NEXTAcademy on 11/21/16.
//  Copyright © 2016 ckhui. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var currentLoc : MKPointAnnotation!
    var venues : [Venue] = []
    var savedIndex = 0
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var resultTableView: UITableView!{
        didSet{
            resultTableView.delegate = self
            resultTableView.dataSource = self
        }
    }
    
    @IBOutlet weak var resultMapView: MKMapView!{
        didSet{
            resultMapView.isHidden = true
        }
    }
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.definesPresentationContext = true
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        
        resultMapView.delegate = self
        
        let query = setQuery(keyWord: "sushi")
        fetchData(query : query)
    }
    @IBAction func indexChanged(_ sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            resultTableView.isHidden = false
            resultMapView.isHidden = true
        case 1:
            resultTableView.isHidden = true
            resultMapView.isHidden = false
        default:
            break;
        }
    }
    
    
    
    func setQuery(keyWord: String) -> String{
        
        let clientId = "MR1O3Y2RJ2GVI0KZA2KNSIUQUHUVLX50PESVIOGX2OZ4DQYR"
        let clientSecret = "BQNMK4ZCVKLWFBXWYU2OPRIIIVA2YGTZF00MSASNH2KKLSBR"
        let lat = 37.78 //583400
        let log = -122.40 //641700
        
        let str = "https://api.foursquare.com/v2/venues/search?client_id=\(clientId)&client_secret=\(clientSecret)&v=20130815&ll=\(lat),\(log)&query=\(keyWord)"
        
        return str
    }
    
    func fetchData(query : String){
        venues = []
        
        let url = URL(string: query)
        
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: {(data,response,error) -> Void in
            do{
                let dict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                let jsonResponse = dict as! NSDictionary
                let a = jsonResponse["response"] as! NSDictionary
                let b = a["venues"] as! [AnyObject]
                for i in b{
                    let i = i as! NSDictionary
                    //let index = self.venues.count
                    let venue = Venue(dict: i)
                    //venue.annotation.accessibilityLabel = "\(index)"
                    self.venues.append(venue)
                    
                }
            }
            catch let error as NSError{
                print("Error : \(error.localizedDescription)")
            }
            
            
            self.resultTableView.reloadData()
            self.setAnnotaion()
            self.optimalWebView()
        })
        task.resume()
    }
    
    func optimalWebView(){
        var maxLat = currentLoc.coordinate.latitude
        var minLat = currentLoc.coordinate.latitude
        var maxLog = currentLoc.coordinate.longitude
        var minLog = currentLoc.coordinate.longitude
        
        for i in venues{
            if i.lat > maxLat{
                maxLat = i.lat
            }
            else if i.lat < minLat{
                minLat = i.lat
            }
            
            if i.lng > maxLog{
                maxLog = i.lng
            }
            else if i.lng < minLog{
                minLog = i.lng
            }
        }
        
        let mapWidth = (maxLat - minLat) * 1.1
        let mapHeight = (maxLog - minLog) * 1.1
        
        
        resultMapView.setRegion(MKCoordinateRegionMake(currentLoc.coordinate, MKCoordinateSpanMake(mapWidth,mapHeight)), animated: true)
    }
    
    func setAnnotaion(){
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let currentLL = locationManager.location
        print ("\(currentLL)")
        
        currentLoc = MKPointAnnotation()
        //let lat = 37.78 //583400
        //let log = -122.40
        currentLoc.coordinate = CLLocationCoordinate2DMake(37.78, -122.40) //(currentLL?.coordinate)!
        currentLoc.title = "You are here"
        
        resultMapView.addAnnotation(currentLoc)
        
        for i in 0...venues.count-1{
            let tempVenue = venues[i]
            tempVenue.annotation.title = "\(i): \(tempVenue.name)"
            resultMapView.addAnnotation(tempVenue.annotation)
        }
        //        for i in venues{
        //            resultMapView.addAnnotation(i.annotation)
        //        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails"{
            let vc = segue.destination as! DetailsViewController
            vc.venue = venues[savedIndex]
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        savedIndex = indexPath.row
        performSegue(withIdentifier: "showDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let temp = venues[indexPath.row]
        cell.textLabel?.text = temp.name
        cell.detailTextLabel?.text = "\(temp.distance)m distance"
        
        return cell
    }
}

extension ViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query = setQuery(keyWord: searchBar.text!)
        fetchData(query : query)
    }
    
}


extension ViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.title! == "You are here"
        {
            let identifier = "Home"
            var annotationView : MKAnnotationView?
            
            if let dequeueAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){
                annotationView = dequeueAnnotationView
                annotationView?.annotation = annotation
                
            }else{
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            
            if let annotationView = annotationView {
                let img = UIImage(named: "youarehere")?.scaledToSize(newSize: CGSize(width: 50, height: 50))
                annotationView.image = img
                annotationView.canShowCallout = true
            }
            
            return annotationView
        }
        else{
            var annotationView : MKPinAnnotationView?
            let identifier = "PinPoint"
            
            if let dequeueAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                annotationView = dequeueAnnotationView
                annotationView?.annotation = annotation
                
            }else{
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            
            if let annotationView = annotationView {
                annotationView.pinTintColor = UIColor.green
                annotationView.canShowCallout = true
            }
            
            return annotationView
        }
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let name = (view.annotation?.title!)!
        if name == "You are here" {
            mapView.setRegion(MKCoordinateRegionMake((view.annotation?.coordinate)!, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
        }
            
        else{
            if (control == view.rightCalloutAccessoryView) {
                if name.characters.index(of: ":") != nil{
                    let str = name.components(separatedBy: ":")
                    let index =  Int(str[0])
                    savedIndex = index!
                    performSegue(withIdentifier: "showDetails", sender: self)
                }
            }
            
        }
    }
    
}

