//
//  UIImageWithEditView.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/13/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class UIImageWithEditView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var editText: UILabel!
    
    @IBOutlet weak var editViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var editViewBottomConstraint: NSLayoutConstraint!
    
    var onEditTapped: ()->() = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }
    
    private func initSubView() {
        let nib = UINib(nibName: "UIImageWithEditView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    @IBAction func onEditTapped(_ sender: UITapGestureRecognizer) {
        onEditTapped()
    }
    
    func hideEditView() {
        editViewBottomConstraint.constant = -22
//        editViewHeightConstraint.constant = 0
//        editImage.isHidden = true
    }
    
    func showEditView() {
        editViewBottomConstraint.constant = 2

//        editViewHeightConstraint.constant = 20
//        editImage.isHidden = false

    }
}
