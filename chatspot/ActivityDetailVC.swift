//
//  ActivityDetailVC.swift
//  chatspot
//
//  Created by Varun on 10/26/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ActivityDetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    var activity: Activity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.target = self
        closeButton.action = #selector(close)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(activity)
        self.title = activity.activityName!
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
