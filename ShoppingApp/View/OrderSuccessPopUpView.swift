//
//  OrderSuccessPopUpView.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/4/24.
//

import UIKit
import Lottie

protocol OrderSuccessPopUpViewDelegate : AnyObject {
    func closePopUp()
}

class OrderSuccessPopUpView: UIView {

    @IBOutlet weak var animationView : LottieAnimationView!
    @IBOutlet weak var mainView : UIView!
    weak var delegate : OrderSuccessPopUpViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 10
        animationView.layer.cornerRadius = 10
        animation()
    }
    
    func animation() {
        animationView.contentMode = .scaleAspectFit
         animationView.loopMode = .playOnce
        animationView.animationSpeed = 2.5
         animationView.play()
    }
    
    @IBAction func cancelBtn(_ sender : UIButton) {
        delegate?.closePopUp()
    }

}


