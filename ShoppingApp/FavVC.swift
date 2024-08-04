//
//  FavVC.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/2/24.
//

import UIKit
import CoreData
import SwiftyJSON

class FavVC: UIViewController {
    
    @IBOutlet weak var favTabView : UITableView!
    
    let cellID = "FavTabViewCell"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var savedIDs = Set<Int>()
    var itemsDict = [Int: ItemModel]()
       var jsonData: JSON?
    var savedIDsForCart = Set<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadFavTab()
        loadJSON(filename: "Shopping.json")
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDataFromCoreData() {
            self.loadCartDataFromCoreData() {
                DispatchQueue.main.async {
                    self.favTabView.reloadData()
                }
            }
        }
    }
    
    func loadFavTab() {
      let nib = UINib(nibName: cellID, bundle: nil)
        favTabView.register(nib, forCellReuseIdentifier: cellID)
        favTabView.separatorStyle = .none
    }
    
    
    @IBAction func backbtn(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func loadDataFromCoreData(completion : @escaping() -> Void) {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let res = data.value(forKey: "id") as AnyObject
                savedIDs.insert(res as! Int)
                
                if let item = getItemModelByID(id: res as! Int) {
                    itemsDict[res as! Int] = item
                              }
            }
            savedIDs = Set(Array(savedIDs).sorted())
        } catch {
            print(error.localizedDescription)
        }
        completion()
    }
    
    func loadCartDataFromCoreData(completion : @escaping() -> Void) {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let res = data.value(forKey: "id") as AnyObject
                savedIDsForCart.insert(res as! Int)
            }
        } catch {
            print(error.localizedDescription)
        }
        completion()
    }
    
    func removeDataFromCoreData(id : Int) {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        request.predicate = NSPredicate(format: "id = %d", id)
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                savedIDs.remove(id)
                context.delete(data)
                itemsDict.removeValue(forKey: id)
            }
            savedIDs = Set(Array(savedIDs).sorted())
            do {
                print("\(id) deleted successfully")
               try context.save()
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeCartDataFromCoreData(id : Int) {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        request.predicate = NSPredicate(format: "id = %d", id)
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                savedIDsForCart.remove(id)
                context.delete(data)
               // itemsDict.removeValue(forKey: id)
            }
            do {
                print("\(id) deleted successfully")
               try context.save()
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveCartToCoreData(id : Double) {
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Cart", in: context)
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
 
    @objc func clickActionFavBtn(_ sender : UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        guard let cell = favTabView.cellForRow(at: indexPath) as? FavTabViewCell else {
               return
           }
  
        
        if cell.favImgView.image == UIImage(named: "heart_fill") {
            
               let alertController = UIAlertController(
                   title: "Remove Favorite",
                   message: "Are you sure you want to remove this item from your favorites?",
                   preferredStyle: .alert
               )

               let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
               let removeAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
                   let id = Array(self.savedIDs)[sender.tag]
                   self.removeDataFromCoreData(id: id)
                   DispatchQueue.main.async {
                       self.favTabView.reloadData()
                   }
               }

               alertController.addAction(cancelAction)
               alertController.addAction(removeAction)

               self.present(alertController, animated: true, completion: nil)
           }
    }
    
    @objc func clickActionForCart(_ sender : UIButton) {
           let indexPath = IndexPath(row: sender.tag, section: 0)
           guard let cell = favTabView.cellForRow(at: indexPath) as? FavTabViewCell else {
                  return
              }
           
           let id = Array(self.savedIDs)[sender.tag]
           
           if cell.cartImgViw.image == UIImage(named: "plus_notAdded") {
               cell.cartImgViw.image = UIImage(named: "plus")
               if !savedIDsForCart.contains(id) {
                   savedIDsForCart.insert(id)
                   saveCartToCoreData(id: Double(id))
               }
           } else if cell.cartImgViw.image == UIImage(named: "plus") {
               cell.cartImgViw.image = UIImage(named: "plus_notAdded")
               if savedIDsForCart.contains(id) {
                   savedIDsForCart.remove(id)
                   removeCartDataFromCoreData(id: id)
               }
           }
       }
}

extension FavVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedIDs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favTabView.dequeueReusableCell(withIdentifier: cellID) as! FavTabViewCell
        let idArray = Array(savedIDs)
              let id = idArray[indexPath.row]
              
              if let item = itemsDict[id] {
                  cell.addItemToFavDetails(detail: item)
              } else {
                  print("Item with ID \(id) not found")
              }
        cell.favImgView.image = UIImage(named: "heart_fill")
        cell.cartImgViw.image = UIImage(named: "plus_notAdded")
        
        cell.favBtn.tag = indexPath.row
        cell.favBtn.addTarget(self, action: #selector(clickActionFavBtn), for: .touchUpInside)
       
        if savedIDsForCart.contains(id) {
                  cell.cartImgViw.image = UIImage(named: "plus")
              } else {
                  cell.cartImgViw.image = UIImage(named: "plus_notAdded")
              }
        
    cell.cartBtn.tag = indexPath.row
cell.cartBtn.addTarget(self, action: #selector(clickActionForCart), for: .touchUpInside)
        
        return cell
    }
}
