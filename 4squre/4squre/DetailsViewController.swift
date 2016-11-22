//
//  DetailsViewController.swift
//  4squre
//
//  Created by NEXTAcademy on 11/21/16.
//  Copyright © 2016 ckhui. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!{
        didSet{
            websiteButton.isEnabled = false
            websiteButton.addTarget(self, action: #selector(onWebsiteButtonPressed(button:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var tipsTabelView: UITableView!{
        didSet{
            tipsTabelView.dataSource = self
            tipsTabelView.estimatedRowHeight = 80
        }
    }
    
    var venue : Venue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let v = venue{
            displayInfo(venue: v)
        }
        tipsTabelView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func displayInfo(venue temp : Venue){
        idLabel.text = temp.id
        nameLabel.text = temp.name
        addressLabel.text = temp.fullAddress()
        locationLabel.text = "\(temp.lat) , \(temp.lng)"
        distanceLabel.text =  "\(temp.distance)"
        
        if temp.phone != nil{
            phoneLabel.text = temp.phone
        }
        
        if temp.url != ""{
            websiteLabel.text = temp.url
            websiteButton.isEnabled = true
        }
        
    }
    
    
    func onWebsiteButtonPressed(button : UIButton){
        performSegue(withIdentifier: "showWebsite", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebsite"{
            let vc = segue.destination as! WebViewController
            vc.url = venue!.url
        }
        
        
    }
    
}

extension DetailsViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (venue?.tips.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            else{
                return UITableViewCell()
        }
        
        let tempTip = venue?.tips[indexPath.row]
        cell.textLabel?.text = tempTip?.text
        cell.textLabel?.numberOfLines = 0
        
        let str = " UP :\(tempTip!.upCount) DOWN :\(tempTip!.downCount)"
        
        cell.detailTextLabel?.text = str
        
        return cell
    }
    
}
