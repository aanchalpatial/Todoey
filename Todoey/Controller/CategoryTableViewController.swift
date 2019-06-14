//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Aanchal Patial on 13/06/19.
//  Copyright © 2019 AP. All rights reserved.
//

import UIKit
import CoreData


class CategoryTableViewController: UITableViewController {
    
    //MARK: - Variables
    
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext      //for Core Data
    var deleteFlag = false
    
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (deleteFlag){                                                                                  //Deletion in Core Data
            context.delete(categoryArray[indexPath.row])
            categoryArray.remove(at: indexPath.row)
            saveNewCategory()
            deleteFlag = false
        }else{
            performSegue(withIdentifier: "goToItemsList", sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    
    //MARK: - Add New Category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            self.saveNewCategory()
        }
        
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write here ..."
            textField = alertTextField
        }
        present(alert,animated: true,completion: nil)
        
        
    }
    
    //MARK: - Delete a Category
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Category", message: "Tap on category which you want to delete.", preferredStyle: .alert)
        present(alert,animated: true,completion: nil)
        let when = DispatchTime.now()+3
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
        deleteFlag = true
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func saveNewCategory() {                                                                               //Creation in core Data
        
        do {
            try context.save()
        }catch {
            print("Error savind context \(error)")
        }
        
        self.tableView.reloadData()
    }
    func loadCategory(with request : NSFetchRequest<Category> = Category.fetchRequest()) {                                                                                  //Reading in Core Data
        do{
            categoryArray = try context.fetch(request)
        }catch {
            print("Error fetching context \(error)")
        }
        tableView.reloadData()
    }
    
    
}
