//
//  HomeVC.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/2/24.
//

import UIKit
import CoreData
import SwiftyJSON

class HomeVC: UIViewController {
    
    @IBOutlet weak var categoryTabView : UITableView!
    @IBOutlet weak var categoriesView : UIView!
    
    var categoryArr = [CategoriesModel]()
    var itemArr = [ItemModel]()
    var categoryItemsDict = [String: [ItemModel]]()
    
    let cellID = "ListTabViewCell"
    var rowHeights = [Int: CGFloat]()
    let minimizedHeight: CGFloat = 45
    let expandedHeight: CGFloat = 270
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var categoriesListPopUpView = CategoriesListPopUpView()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTab()
        categoriesView.layer.cornerRadius = 7
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDataForCategories() {
            DispatchQueue.main.async {
                self.categoryTabView.reloadData()
            }
        }
    }
    
    func loadTab() {
        let nib = UINib(nibName: cellID, bundle: nil)
        categoryTabView.register(nib, forCellReuseIdentifier: cellID)
        categoryTabView.separatorStyle = .none
    }
    
    
    func loadJSON(filename: String) -> JSON? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("Failed to locate \(filename) in bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSON(data: data)
            return json
        } catch {
            print("Failed to decode \(filename) from bundle: \(error)")
            return nil
        }
    }
    
    func extractCategories(from json: JSON) -> [CategoriesModel] {
        var categories = [CategoriesModel]()
        let categoriesArray = json["categories"].arrayValue
        
        for categoryJSON in categoriesArray {
            let id = categoryJSON["id"].intValue
            let name = categoryJSON["name"].stringValue
            
            var items = [ItemModel]()
            let itemsArray = categoryJSON["items"].arrayValue
            
            for itemJSON in itemsArray {
                let itemId = itemJSON["id"].intValue
                let itemName = itemJSON["name"].stringValue
                let icon = itemJSON["icon"].stringValue
                let price = itemJSON["price"].doubleValue
                
                let item = ItemModel(id: itemId, name: itemName, icon: icon, price: price)
                items.append(item)
            }
            
            let category = CategoriesModel(id: id, name: name, items: items)
            categories.append(category)
            
            categoryItemsDict[name] = items
        }
        
        return categories
    }
    
    func loadDataForCategories(completion: @escaping () -> Void) {
        if let json = loadJSON(filename: "Shopping.json") {
            categoryArr = extractCategories(from: json)
            for category in categoryArr {
                print("Category: \(category.name)")
                for item in category.items {
                    print("  Item: \(item.name) - \(item.price)")
                }
            }
        }
        completion()
    }
    
    
    @IBAction func favBtn(_ sender : UIButton) {
        let fvc = self.storyboard?.instantiateViewController(identifier: "FavVC") as! FavVC
        self.navigationController?.pushViewController(fvc, animated: true)
    }
    
    @IBAction func cartBtn(_ sender : UIButton) {
        let cvc = self.storyboard?.instantiateViewController(identifier: "CartVC") as! CartVC
        self.navigationController?.pushViewController(cvc, animated: true)
    }
    
    
    @objc func minimizeBtnClick(_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        guard let cell = categoryTabView.cellForRow(at: indexPath) as? ListTabViewCell else {
            return
        }
      
        let currentHeight = rowHeights[indexPath.row] ?? expandedHeight
        let newHeight: CGFloat
        
        if currentHeight == expandedHeight {
            cell.minimizeImgView.image = UIImage(named: "arrow_down")
            newHeight = minimizedHeight
        } else {
            cell.minimizeImgView.image = UIImage(named: "arrow_up")
            newHeight = expandedHeight
        }
        
        rowHeights[indexPath.row] = newHeight
        
        // Reloading the specific row to apply the height change
        categoryTabView.beginUpdates()
        categoryTabView.reloadRows(at: [indexPath], with: .automatic)
        categoryTabView.endUpdates()
        
        
    }
    
    @IBAction func categoriesBtn(_ sender : UIButton) {
        openCategoriesListPopUp()
    }
    
    func openCategoriesListPopUp() {
        categoriesListPopUpView = Bundle.main.loadNibNamed("CategoriesListPopUpView", owner: nil, options: nil)![0] as! CategoriesListPopUpView
        categoriesListPopUpView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        categoriesListPopUpView.delegate = self
        var items = [String]()
        for category in categoryArr {
            items.append(category.name)
        }
        print("items count", items)
        categoriesListPopUpView.getCategories(items: items)
        self.view.addSubview(categoriesListPopUpView)
    }
}
extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("categoryArr.count", categoryArr.count)
        return categoryArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeights[indexPath.row] ?? expandedHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTabView.dequeueReusableCell(withIdentifier: cellID) as! ListTabViewCell
        if rowHeights[indexPath.row] == expandedHeight {
            cell.minimizeImgView.image = UIImage(named: "arrow_down")
        } else if rowHeights[indexPath.row] == minimizedHeight {
            cell.minimizeImgView.image = UIImage(named: "arrow_up")
        }
        
        cell.categoryName.text = categoryArr[indexPath.row].name
        
        if let items = categoryItemsDict[categoryArr[indexPath.row].name] {
                   cell.items = items
               } else {
                   cell.items = []
                   print("items are empty")
               }
        cell.minimizeBtn.tag = indexPath.row
        cell.minimizeBtn.addTarget(self, action: #selector(minimizeBtnClick), for: .touchUpInside)
        return cell
    }
}
extension HomeVC : CategoriesListPopUpViewDelegate {
    
    func getSelectedItem(_ item: String, _ selectedRow: Int) {
        let indexPath = IndexPath(row: selectedRow, section: 0)
        guard let cell = categoryTabView.cellForRow(at: indexPath) as? ListTabViewCell else {
            return
        }
      
        let currentHeight = rowHeights[indexPath.row] ?? expandedHeight
        let newHeight: CGFloat
       
        if currentHeight == minimizedHeight {
            cell.minimizeImgView.image = UIImage(named: "arrow_up")
            newHeight = expandedHeight
            rowHeights[indexPath.row] = newHeight
            categoryTabView.beginUpdates()
            categoryTabView.reloadRows(at: [indexPath], with: .automatic)
            categoryTabView.endUpdates()
        }
        }

    func closePopUp() {
        categoriesListPopUpView.removeFromSuperview()
    }
}
