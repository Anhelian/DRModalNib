//
//  ModalView.swift
//  ModalView
//
//  Created by Denis Romashov on 18.09.2017.
//  Copyright © 2017 Denis Romashov. All rights reserved.
//

import UIKit

class ModalView: DRBaseModalNib {
    public class func loadView() -> ModalView {
        return Bundle.main.loadNibNamed("ModalView", owner: self, options: nil)?.first as! ModalView
    }
    
}
