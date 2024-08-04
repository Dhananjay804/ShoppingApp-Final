//
//  SplashScreenVC.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/2/24.
//

import UIKit
import Lottie

class SplashScreenVC: UIViewController {
    
    @IBOutlet var animationView : LottieAnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        animation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            let hvc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(hvc, animated: true)
               }
        
    }
    
    func animation() {
        animationView.contentMode = .scaleAspectFit
         animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
         animationView.play()
    }


}

