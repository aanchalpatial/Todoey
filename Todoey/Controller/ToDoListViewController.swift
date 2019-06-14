//
//  ViewController.swift
//  Todoey
//
//  Created by Aanchal Patial on 07/06/19.
//  Copyright © 2019 AP. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    //MARK: - Variables
    
    var itemArray = [Item]()
    let defaults = UserDefaults.standard                                                               //for User Defaults Method
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")                                  //for NSCoder Method
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext      //for Core Data
    var deleteFlag = false
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //        if let item = defaults.array(forKey: "itemArrayList") as? [Item] {
        //            itemArray = item
        //        }
        //loadItems()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        //Ternany Operator
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if (deleteFlag){                                                                                  //Deletion in Core Data
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            saveNewItems()
            deleteFlag = false
        }else{
            itemArray[indexPath.row].done = !itemArray[indexPath.row].done                                //Updation in Core Data
            saveNewItems()
            }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Item
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false                //In Items Entity done is not an optional
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveNewItems()
            
            
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write here ..."
            textField = alertTextField
        }
        present(alert,animated: true,completion: nil)
    }
    
    //MARK: - Delete Items
    
    
    @IBAction func deleteItem(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Item", message: "Tap on item which you want to delete.", preferredStyle: .alert)
//        let action = UIAlertAction(title: "Delete", style: .default) { (action) in
//            //do nothing
//        }
//        alert.addAction(action)
        present(alert,animated: true,completion: nil)
        let when = DispatchTime.now()+3
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
        deleteFlag = true
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveNewItems() {                                                                               //Creation in core Data
        
        
        do {
            try context.save()
        }catch {
            print("Error savind context \(error)")
        }
        
        self.tableView.reloadData()
    }
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {                                                                                  //Reading in Core Data
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES[cd] %@", selectedCategory!.name!)
        
        if let searchPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate,categoryPredicate])
        }else {
            request.predicate = categoryPredicate
        }
        do{
            itemArray = try context.fetch(request)
        }catch {
            print("Error fetching context \(error)")
        }
        tableView.reloadData()
    }

}
//MARK: - Extensions

extension ToDoListViewController : UISearchBarDelegate {                                                //Searching in Core Data
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with : request , predicate: searchPredicate)
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

