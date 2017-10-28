//
//  AroundMeVC.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class AroundMeVC: UIViewController {

    @IBOutlet weak var aroundMeView: AroundMeView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setUpTitle(title: "Around Me")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }

}
