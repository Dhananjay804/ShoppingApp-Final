//
//  CartVC.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/3/24.
//

import UIKit
import SwiftyJSON
import CoreData

class CartVC: UIViewController {
    
    @IBOutlet weak var cartTabView : UITableView!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var calView : UIView!
    @IBOutlet weak var orderBtnView : UIView!
    
    let cellID = "CartTabViewCell"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var savedIDs = Set<Int>()
    var itemsDict = [Int: ItemModel]()
    var itemQuantities = [Int: Int]()
    var jsonData: JSON?
    var orderSuccessPopUpView = OrderSuccessPopUpView()
    var totalAmount : Double = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        calView.isHidden = true
        orderBtnView.isHidden = true
        calView.layer.cornerRadius = 20
        orderBtnView.layer.cornerRadius = 20
        loadCartTab()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadJSON(filename: "Shopping.json")
        loadDataFromCoreData() { [self] in
            if !savedIDs.isEmpty {
                calView.isHidden = false
                orderBtnView.isHidden = false
              //  animateOrderBtnView()
                DispatchQueue.main.async {
                    self.cartTabView.reloadData()
                    self.updateSummaryLabels()
                }
            } else {
                calView.isHidden = true
                orderBtnView.isHidden = true
            }
        }
    }
    
    func animateOrderBtnView() {
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            options: [.autoreverse, .repeat],
            animations: {
                self.orderBtnView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            },
            completion: { _ in
                self.orderBtnView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            }
        )
    }

   
    
    func loadCartTab() {
        let nib = UINib(nibName: cellID, bundle: nil)
        cartTabView.register(nib, forCellReuseIdentifier: cellID)
        cartTabView.separatorStyle = .none
    }
    
    @IBAction func backBtn(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func orderNowBtn(_ sender : UIButton) {
        
        if totalAmount > 0 {
            
            orderSuccessPopUp()
        }
    }
    
    func orderSuccessPopUp() {
        orderSuccessPopUpView = Bundle.main.loadNibNamed("OrderSuccessPopUpView", owner: nil, options: nil)![0] as! OrderSuccessPopUpView
        orderSuccessPopUpView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        orderSuccessPopUpView.delegate = self
        self.view.addSubview(orderSuccessPopUpView)
    }
    
    func loadDataFromCoreData(completion : @escaping() -> Void) {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let res = data.value(forKey: "id") as AnyObject
                savedIDs.insert(res as! Int)
                
                if let item = getItemModelByID(id: res as! Int) {
                    itemsDict[res as! Int] = item
                    itemQuantities[res as! Int] = 1
                              }
            }
        } catch {
            print(error.localizedDescription)
        }
        completion()
    }
    
    func removeDataFromCoreData(id: Int) {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        request.predicate = NSPredicate(format: "id = %d", id)
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                context.delete(data)
            }
            
            do {
                try context.save()
                print("\(id) deleted successfully")
                
                savedIDs.remove(id)
                itemsDict.removeValue(forKey: id)
                itemQuantities.removeValue(forKey: id)
            } catch {
                print("Error saving context after deletion: \(error.localizedDescription)")
            }
        } catch {
            print("Error fetching data for deletion: \(error.localizedDescription)")
        }
    }
    
    func saveFavToCoreData(id : Double) {
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Favorites", in: context)
        let newID = NSManagedObject(entity: entity!, insertInto: context)
        newID.setValue(id, forKey: "id")
        
        do {
            try context.save()
            print("\(id), Saved to core data")
        } catch {
            print("Error Saving")
        }
    }

    
  
    
    func loadJSON(filename: String) {
          guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
              print("Failed to locate \(filename) in bundle.")
              return
          }
          
          do {
              let data = try Data(contentsOf: url)
              jsonData = try JSON(data: data)
          } catch {
              print("Failed to decode \(filename) from bundle: \(error)")
          }
      }
    
    func getItemModelByID(id: Int) -> ItemModel? {
          guard let json = jsonData else {
              return nil
          }
          
          for category in json["categories"].arrayValue {
              for itemJSON in category["items"].arrayValue {
                  if itemJSON["id"].intValue == id {
                      let itemId = itemJSON["id"].intValue
                      let itemName = itemJSON["name"].stringValue
                      let icon = itemJSON["icon"].stringValue
                      let price = itemJSON["price"].doubleValue
                      return ItemModel(id: itemId, name: itemName, icon: icon, price: price)
                  }
              }
          }
          return nil
      }
    
    @objc func clickActionCartBtn(_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        guard let cell = cartTabView.cellForRow(at: indexPath) as? CartTabViewCell else {
            return
        }

        let alertController = UIAlertController(
            title: "Remove Item",
            message: "Are you sure you want to remove this item from your cart?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
            let idArray = Array(self.savedIDs)
            let id = idArray[sender.tag]
            
            // Remove from Core Data
            self.removeDataFromCoreData(id: id)
            
            // Remove the row from the table view
            //self.cartTabView.beginUpdates()
            
            // Update local data source
            self.savedIDs.remove(id)
            self.itemsDict.removeValue(forKey: id)
            
            DispatchQueue.main.async {
                self.cartTabView.reloadData()
            }
            self.updateSummaryLabels()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(removeAction)

        self.present(alertController, animated: true, completion: nil)
    }

    
    @objc func clickActionplusBtn(_ sender : UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
            guard let cell = cartTabView.cellForRow(at: indexPath) as? CartTabViewCell else {
                return
            }

            let idArray = Array(savedIDs)
            let id = idArray[sender.tag]
            guard let item = itemsDict[id] else {
                return
            }

            var quantity = itemQuantities[id] ?? 1
            quantity += 1
            itemQuantities[id] = quantity

            cell.quantityLb.text = String(quantity)
        cell.itemAmount.text = String(format: "%.2f", item.price * Double(quantity))
        updateSummaryLabels()
      
    }
    
    @objc func clickActionMinusBtn(_ sender : UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
             guard let cell = cartTabView.cellForRow(at: indexPath) as? CartTabViewCell else {
                 return
             }

             let idArray = Array(savedIDs)
             let id = idArray[sender.tag]
             guard let item = itemsDict[id] else {
                 return
             }

             var quantity = itemQuantities[id] ?? 1
             quantity = max(1, quantity - 1)
             itemQuantities[id] = quantity

             cell.quantityLb.text = String(quantity)
             cell.itemAmount.text = String(format: "%.2f",item.price * Double(quantity))
        updateSummaryLabels()
    }
    
    func updateSummaryLabels() {
        var subtotal: Double = 0.0

        for (id, quantity) in itemQuantities {
            if let price = itemsDict[id]?.price {
                subtotal += price * Double(quantity)
            }
        }

        let discount = subtotal * 0.20
        let total = subtotal - discount

        subtotalLabel.text = "Rs: \(String(format: "%.2f", subtotal))"
        discountLabel.text = "Rs: \(String(format: "%.2f", discount))"
        totalLabel.text = "Rs: \(String(format: "%.2f", total))"
        totalAmount = total
    }

    
    
    

}
extension CartVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedIDs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cartTabView.dequeueReusableCell(withIdentifier: cellID) as! CartTabViewCell
        let idArray = Array(savedIDs)
              let id = idArray[indexPath.row]
              
              if let item = itemsDict[id] {
                  cell.addItemToCartDetails(detail: item)
        cell.quantityLb.text = String(itemQuantities[id] ?? 1)
    cell.itemAmount.text = "\(String(format: "%.2f", item.price * Double(itemQuantities[id] ?? 1)))"


              } else {
                  print("Item with ID \(id) not found")
              }
        cell.closeBtn.tag = indexPath.row
        cell.closeBtn.addTarget(self, action: #selector(clickActionCartBtn), for: .touchUpInside)
        
        cell.plusBtn.tag = indexPath.row
        cell.plusBtn.addTarget(self, action: #selector(clickActionplusBtn), for: .touchUpInside)
        
        cell.minusBtn.tag = indexPath.row
        cell.minusBtn.addTarget(self, action: #selector(clickActionMinusBtn), for: .touchUpInside)
        return cell
    }
}
extension CartVC : OrderSuccessPopUpViewDelegate {
    func closePopUp() {
        orderSuccessPopUpView.removeFromSuperview()
    }
    
    
}
