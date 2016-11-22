//
//  WebViewController.swift
//  4squre
//
//  Created by NEXTAcademy on 11/21/16.
//  Copyright © 2016 ckhui. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    var url = ""
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadWeb()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadWeb(){
        if url != ""{
            //webView.delegate = self
            if let webUrl = URL(string: url) {
                let request = URLRequest(url: webUrl)
                webView.loadRequest(request)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
