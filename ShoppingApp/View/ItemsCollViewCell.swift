//
//  ItemsCollViewCell.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/2/24.
//

import UIKit
import SDWebImage

class ItemsCollViewCell: UICollectionViewCell {
    
    @IBOutlet weak var favBtn : UIButton!
    @IBOutlet weak var favImgView : UIImageView!
    @IBOutlet weak var itemImg : UIImageView!
    @IBOutlet weak var itemNameLb : UILabel!
    @IBOutlet weak var itemNamePrice : UILabel!
    @IBOutlet weak var addToCartBtn : UIButton!
    @IBOutlet weak var itemsView : UIView!
    @IBOutlet weak var cartImgView : UIImageView!
    @IBOutlet weak var cartBtn : UIButton!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        itemsView.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemImg.image = nil
        favImgView.image = nil
    }
    
    
    func addItemDetails(detail : ItemModel) {
        itemNameLb.text = detail.name
        itemNamePrice.text = "Rs: " + String(detail.price)
        let url = URL(string: detail.icon)
        itemImg.sd_setImage(with: url, placeholderImage: UIImage(named: "ImageNotAvailable")) { [weak self] (image, error, cacheType, imageURL) in
            // Check if the cell is still visible
            guard self != nil else { return }

            if error != nil {
                print("Error loading image: \(error!.localizedDescription)")
            }
        }
     
    }

}
