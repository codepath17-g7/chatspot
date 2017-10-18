//
//  ChatRoomAnnotationDetailView.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/18/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ChatRoomAnnotationDetailView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var roomImage: UIImageView!
    
    @IBOutlet weak var userCountLabel: UILabel!
    
    @IBOutlet weak var joinButton: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }
    
    private func initSubView() {
        let nib = UINib(nibName: "ChatRoomAnnotationDetailView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
}
