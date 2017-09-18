//
//  ViewController.swift
//  ModalView
//
//  Created by Denis Romashov on 18.09.2017.
//  Copyright © 2017 Denis Romashov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet var animationSwitchers: [UISwitch]!
    @IBOutlet weak var showAtViewSwitch: UISwitch!
    
    var modalView = ModalView()
    var animationType = DRBaseModalAnimation.popUp
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Modal View Example"
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            
        }
    }
    
    //MARK: - Actions
    
    @IBAction func topButtonPressed(_ sender: UIButton) {
        showModalView(DRBaseModalPosition.top, animationType: animationType)
    }
    
    @IBAction func centerButtonPressed(_ sender: UIButton) {
        showModalView(DRBaseModalPosition.center, animationType: animationType)
    }
    
    @IBAction func bottomButtonPressed(_ sender: Any) {
        showModalView(DRBaseModalPosition.bottom, animationType: animationType)
    }
    
    @IBAction func animationSwitchPressed(_ sender: UISwitch) {
        for switcher in animationSwitchers {
            if switcher.tag != sender.tag {
               switcher.setOn(false, animated: true)
            }
        }
        
        switch sender.tag {
        case 0:
            animationType = DRBaseModalAnimation.popUp
        case 1:
            animationType = DRBaseModalAnimation.fadeIn
        case 2:
            animationType = DRBaseModalAnimation.none
        default:
            animationType = DRBaseModalAnimation.popUp
            
        }
        
        
    }
    
    
    func showModalView(_ position : DRBaseModalPosition, animationType type: DRBaseModalAnimation) {
        modalView = ModalView.loadView()
        
        if showAtViewSwitch.isOn {
            modalView.show(on: view, at: position, withAnimationType: type)
        } else {
            modalView.show(at: position, withAnimationType: type)
        }
    }
    
    
    // TODO: Add Settings
    
}

