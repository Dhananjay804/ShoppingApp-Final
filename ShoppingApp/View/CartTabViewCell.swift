//
//  CartTabViewCell.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/3/24.
//

import UIKit

class CartTabViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView : UIImageView!
    @IBOutlet weak var itemName : UILabel!
    @IBOutlet weak var itemPrice : UILabel!
    @IBOutlet weak var itemAmount : UILabel!
    @IBOutlet weak var closeBtn : UIButton!
    @IBOutlet weak var plusBtn : UIButton!
    @IBOutlet weak var minusBtn : UIButton!
    @IBOutlet weak var quantityLb : UILabel!
    @IBOutlet weak var mainView : UIView!
    @IBOutlet weak var plusView : UIView!
    @IBOutlet weak var minusView : UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        minusView.layer.cornerRadius = 5
        plusView.layer.cornerRadius = 5
        mainView.layer.cornerRadius = 15
    }

    func addItemToCartDetails(detail : ItemModel) {
        itemName.text = detail.name
        itemPrice.text = "Rs: " + String(detail.price)
        let url = URL(string: detail.icon)
        itemImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "ImageNotAvailable")) { [weak self] (image, error, cacheType, imageURL) in
            // Check if the cell is still visible
            guard self != nil else { return }

            if error != nil {
                print("Error loading image: \(error!.localizedDescription)")
            }
        }
     
    }
    
}
