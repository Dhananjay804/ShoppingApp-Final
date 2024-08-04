//
//  FavTabViewCell.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/2/24.
//

import UIKit

class FavTabViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImgView : UIImageView!
    @IBOutlet weak var itemName : UILabel!
    @IBOutlet weak var itemPrice : UILabel!
    @IBOutlet weak var favBtn : UIButton!
    @IBOutlet weak var cartBtn : UIButton!
    
    @IBOutlet weak var favImgView : UIImageView!
    @IBOutlet weak var cartImgViw : UIImageView!
    @IBOutlet weak var mainView : UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 10
    }
    
    func addItemToFavDetails(detail : ItemModel) {
        itemName.text = detail.name
        itemPrice.text = "Rs: " + String(detail.price)
        let url = URL(string: detail.icon)
        itemImgView.sd_setImage(with: url, placeholderImage: UIImage(named: "ImageNotAvailable")) { [weak self] (image, error, cacheType, imageURL) in
            // Check if the cell is still visible
            guard self != nil else { return }

            if error != nil {
                print("Error loading image: \(error!.localizedDescription)")
            }
        }
     
    }
    
    

    
}
