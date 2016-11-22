//
//  File.swift
//  4squre
//
//  Created by NEXTAcademy on 11/21/16.
//  Copyright © 2016 ckhui. All rights reserved.
//

import Foundation
import MapKit

class Venue{
    var id : String
    var name : String
    var address : [String]
    var distance : Double
    var lng : Double
    var lat : Double
    var phone : String?
    var url : String = ""
    var annotation : MKPointAnnotation!
    var categories : [String] = []
    var tips : [Tip] = []
    
    init(dict : NSDictionary){
        id = dict["id"] as! String
        name = dict["name"] as! String
        
        //
        let contact = dict["contact"] as! [String : AnyObject]
        //print("\(contact)")
        if let phoneNo = contact["formattedPhone"] as? String{
            phone = phoneNo
        }
        
        //print(dict["url"])
        if let venueUrl = dict["url"] as? String{
            url = venueUrl
        }
        
        
        //address,distance,lat,lng
        let loc = dict["location"] as! [String : AnyObject]
        lat = loc["lat"] as! Double
        lng = loc["lng"] as! Double
        distance = loc["distance"] as! Double
        let add = loc["formattedAddress"] as! [String]
        address = add
        
        //category
        let category = dict["categories"] as! [AnyObject]
        for cat in category {
            let cat = cat as! NSDictionary
            let str = cat["name"] as! String
            categories.append(str)
        }
//        category["id"] as! String
//        category["pluralName"] as! String
//        category["name"] as! String
//        category["shortName"] as! String
//        category["primary"] as! Int
//        let icon = category["icon"] as! NSDictionary
//        icon["prefix"] as! String
//        icon["suffix"] as! String
        
        //review
        let queryUrl = setTipsQuery()
        fetchTipsData(query: queryUrl)
        
        annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(lat, lng)
        annotation.title = name
        annotation.subtitle = phone
        
        
    }
    
    func setTipsQuery() -> String{
        let clientId = "MR1O3Y2RJ2GVI0KZA2KNSIUQUHUVLX50PESVIOGX2OZ4DQYR"
        let clientSecret = "BQNMK4ZCVKLWFBXWYU2OPRIIIVA2YGTZF00MSASNH2KKLSBR"
        let venueId = id
        
        
        let str = "https://api.foursquare.com/v2/venues/\(venueId)/tips?client_id=\(clientId)&client_secret=\(clientSecret)&v=20130815"
        
        return str
    }

    
    func fetchTipsData(query : String){
        tips = []
        
        let url = URL(string: query)
        
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: {(data,response,error) -> Void in
            do{
                let dict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                let jsonResponse = dict as! NSDictionary
                let a = jsonResponse["response"] as! NSDictionary
                let b = a["tips"] as! NSDictionary
                let c = b["items"] as! [AnyObject]
                
                for review in c{
                    let temptip = Tip()
                    let review = review as! NSDictionary
                    temptip.downCount = review["disagreeCount"] as! Int
                    temptip.upCount = review["agreeCount"] as! Int
                    temptip.text = review["text"] as! String
                    self.tips.append(temptip)
                }
            }
            catch let error as NSError{
                print("Error : \(error.localizedDescription)")
            }

        })
        task.resume()
    }
    
    
    func fullAddress() -> String{
        return address.joined(separator: ",")
    }
    
    /*
     i["id"] as! String
     i["name"] as! String
     let loc = i["location"] as! [String : AnyObject]  //address,distance,lat,lng
     loc["lat"]!
     loc["lng"]!
     loc["distance"]!
     loc["address"]!
     
     i["categories"] as! [AnyObject]
     i["stats"] as! [String : AnyObject]
     i["venueChains"] as! [AnyObject]
     i["contact"] as! [String : AnyObject]
     
     */
    
    /*
     self.venueId = json["id"].string
     self.name = json["name"].string
     self.address = json["location"]["address"].string
     self.latitude = json["location"]["lat"].double
     self.longitude = json["location"]["lng"].double
     self.categoryIconURL = nil
     
     // Primary Category
     if let categories = json["categories"].array {
     if !categories.isEmpty {
     let prefix = json["categories"][0]["icon"]["prefix"].string
     let suffix = json["categories"][0]["icon"]["suffix"].string
     let iconUrlString = String(format: "%@%d%@", prefix!, kCategoryIconSize, suffix!)
     self.categoryIconURL = URL(string: iconUrlString as String)
     }
     
     
     
     */
    
}

extension UIImage {
    func scaledToSize (newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

class Tip{
    var text : String = ""
    var upCount : Int = 0
    var downCount : Int = 0
}
