//
//  ListTabViewCell.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/2/24.
//

import UIKit
import CoreData

class ListTabViewCell: UITableViewCell {
    
    @IBOutlet weak var minimizeBtn : UIButton!
    @IBOutlet weak var minimizeImgView : UIImageView!
    @IBOutlet weak var itemsCollView : UICollectionView!
    @IBOutlet weak var categoryName : UILabel!
    
    private let spacing : CGFloat = 10
    let cellID = "ItemsCollViewCell"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var savedIDs = Set<Int>()
    var savedIDsForCart = Set<Int>()
    
    var items = [ItemModel]() {
           didSet {
               DispatchQueue.main.async {
                   self.itemsCollView.reloadData()
               }
              
           }
       }
    
    
    var collectionViewOffset: CGFloat {
        get {
            return itemsCollView.contentOffset.x
        }

        set {
            itemsCollView.contentOffset.x = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadCollectionViewContraints()
        loadCollectionView()

    }
    
    func loadCollectionViewContraints() {
    let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.itemsCollView.collectionViewLayout = layout
    }
    
    func loadCollectionView() {
        let nib = UINib(nibName: cellID, bundle: nil)
        itemsCollView.register(nib, forCellWithReuseIdentifier: cellID)
    }

    func loadDataFromCoreData(completion : @escaping() -> Void) {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let res = data.value(forKey: "id") as AnyObject
                savedIDs.insert(res as! Int)
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
            savedIDs = Set(Array(savedIDs).sorted())
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
    
    @objc func clickAction(_ sender : UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        guard let cell = itemsCollView.cellForItem(at: indexPath) as? ItemsCollViewCell else {
               return
           }
        if  cell.favImgView.image == UIImage(named: "heart_fill") {
cell.favImgView.image = UIImage(named: "heart_empty")
            if savedIDs.contains(items[sender.tag].id) {
                savedIDs.remove(items[sender.tag].id)
        removeDataFromCoreData(id: items[sender.tag].id)
            }
        } else if cell.favImgView.image == UIImage(named: "heart_empty") {
cell.favImgView.image = UIImage(named: "heart_fill")
if !savedIDs.contains(items[sender.tag].id) {
    savedIDs.insert(items[sender.tag].id)
    saveFavToCoreData(id: Double(items[sender.tag].id))
            }
        }
    }
    
    @objc func clickActionForCart(_ sender : UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        guard let cell = itemsCollView.cellForItem(at: indexPath) as? ItemsCollViewCell else {
               return
           }
    if  cell.cartImgView.image == UIImage(named: "plus") {
cell.cartImgView.image = UIImage(named: "plus_notAdded")
    if savedIDsForCart.contains(items[sender.tag].id) {
    savedIDsForCart.remove(items[sender.tag].id)
    removeCartDataFromCoreData(id: items[sender.tag].id)
            }
        } else if cell.cartImgView.image == UIImage(named: "plus_notAdded") {
cell.cartImgView.image = UIImage(named: "plus")
if !savedIDsForCart.contains(items[sender.tag].id) {
    savedIDsForCart.insert(items[sender.tag].id)
    saveCartToCoreData(id: Double(items[sender.tag].id))
            }
        }
    }
}
extension ListTabViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 170, height: 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = itemsCollView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath as IndexPath) as! ItemsCollViewCell
        cell.clipsToBounds = true
        print("savedIDs all", savedIDs)
        cell.favImgView.image = UIImage(named: "heart_empty")
        cell.cartImgView.image = UIImage(named: "plus_notAdded")
        savedIDs.removeAll()
        savedIDsForCart.removeAll()
        print("savedIDsForCart", savedIDsForCart)
        loadCartDataFromCoreData { [self] in
if savedIDsForCart.contains(items[indexPath.row].id) {
    cell.cartImgView.image = UIImage(named: "plus")
            } else {
    cell.cartImgView.image = UIImage(named: "plus_notAdded")
            }
        }
        cell.cartBtn.tag = indexPath.row
        cell.cartBtn.addTarget(self, action: #selector(clickActionForCart), for: .touchUpInside)
        
        
        loadDataFromCoreData() { [self] in
if savedIDs.contains(items[indexPath.row].id) {
                cell.favImgView.image = UIImage(named: "heart_fill")
            } else {
                cell.favImgView.image = UIImage(named: "heart_empty")
            }
        }
        cell.addItemDetails(detail: items[indexPath.row])
        cell.favBtn.tag = indexPath.row
        cell.favBtn.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
        return cell
    }
}
