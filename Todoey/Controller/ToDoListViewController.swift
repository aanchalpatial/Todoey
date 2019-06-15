//
//  ViewController.swift
//  Todoey
//
//  Created by Aanchal Patial on 07/06/19.
//  Copyright © 2019 AP. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    //MARK: - Variables
    
    var toDoItems : Results<Item>?
    let defaults = UserDefaults.standard                                                               //for User Defaults Method
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")                                  //for NSCoder Method
    //    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext      //for Core Data
    let realm = try! Realm()                                                                            //for Realm Method
    
    var deleteFlag = false
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            
            var dateString = ""
            if let itemDate = item.dateCreated {
                dateString = itemDate.toString(dateFormat : "dd-MM HH:mm:ss")
            }
            
            cell.textLabel?.text = item.title + " @ " + dateString
            //Ternany Operator
            cell.accessoryType = item.done ? .checkmark : .none
        }else {
            cell.textLabel?.text = "No items added yet ..."
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let item = toDoItems?[indexPath.row] {
            do{
                try realm.write {
                    if (deleteFlag){
                        realm.delete(item)                                                          //Delete in Realm
                        deleteFlag = false
                    }
                    else {
                        item.done = !item.done                                                      //Update in Realm
                    }
                }
            }catch{
                print("error updating Checkmark \(error)")
            }
        }
        tableView.reloadData()
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    //MARK: - Add New Item
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {                                                //Create in Realm
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch {
                    print("Error saving into Realm \(error)")
                }
            }
            self.tableView.reloadData()
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
    
    
    func loadItems() {                                                                                    //Read in Realm
        
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
}

//MARK: - Extensions

extension ToDoListViewController : UISearchBarDelegate {                                                //Search in Realm
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
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

extension Date {
    func toString(dateFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

