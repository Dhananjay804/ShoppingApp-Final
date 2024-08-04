//
//  CategoriesListPopUpView.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/3/24.
//

import UIKit

protocol CategoriesListPopUpViewDelegate : AnyObject {
    func closePopUp()
    func getSelectedItem(_ item : String, _ selectedRow : Int)
}

class CategoriesListPopUpView: UIView {

    @IBOutlet weak var pickerView : UIPickerView!
    @IBOutlet weak var mainView : UIView!
    @IBOutlet weak var selectView : UIView!
    @IBOutlet weak var animationView : UIView!
    weak var delegate : CategoriesListPopUpViewDelegate?
    var totalItems = [String]()
    var selectedRow = Int()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 10
        selectView.layer.cornerRadius = 6
        pickerView.dataSource = self
        pickerView.delegate = self
        
        animationView.frame.origin.y = self.frame.height
            
               UIView.animate(withDuration: 0.8, animations: {
                   self.animationView.frame.origin.y = self.frame.height - self.animationView.frame.height
               })
    }
    
    @IBAction func cancelBtn(_ sender : UIButton) {
        delegate?.closePopUp()
    }
    
    @IBAction func selectBtn(_ sender : UIButton) {
        delegate?.getSelectedItem(totalItems[selectedRow], selectedRow)
        delegate?.closePopUp()
    }
    
    func getCategories(items :  [String]) {
        totalItems = items
        print("totalItems", totalItems)
        pickerView.reloadAllComponents()
    }
    
    
}
extension CategoriesListPopUpView : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return totalItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return totalItems[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}
