//
//  ViewController.swift
//  ToDoList
//
//  Created by Deka Primatio on 30/05/22.
//

import UIKit

// Library UI yang digunakan TableViewDelegate dan TableViewDataSource
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Buat context dengan AppDelegate dan cast context ke persistentContainer (database)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Buat Tabel dengan UITableView
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    private var models = [ToDoListItem]() // models yang berisikan List Item (Task) dalam bentuk array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CoreData To Do List" // Judul Halaman
        view.addSubview(tableView)
        getAllItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        // Tombol + dengan fungsi dalam bentuk Selector Object (@objc)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    // Custom Pop Up Alert -> Klik + -> Muncul Pop Up -> Isi Task -> Submit
    @objc private func didTapAdd(){

        // Forms
        let alert = UIAlertController(title: "New Item", message: "Enter New Item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        // Tombol Submit ketika ditekan akan close pop up
        // [weak self] Memory Leak Handler
        // Guard untuk menghandle pengisian
        // Jika diisi maka akan ada task baru & jika kosong maka tidak akan ada task baru
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else{
                return
            }
            
            // buat task baru
            self?.createItem(name: text)
            
        }))
        
        // Animasi Pop Up Alert
        present(alert, animated: true)
    }
    
    // Fungsi untuk menghitung dan menampilkan banyaknya task yang muncul berdasarkan database
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    // Menampilkan hasil item (task) yang di input ke dalam cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        
        // Pengecekan tanggal dan waktu dibuatnya task
        //        cell.textLabel?.text = "\(model.name) - \(model.createdAt)"
        
        return cell
    }
    
    // Fungsi edit item (Task) = klik item -> edit -> pop up form editable -> simpan
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        
        // memunculkan ActionSheet Edit dibawah ketika memilih salah satu item (task)
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        // memunculkan ActionSheet Cancel dibawah ketika memilih salah satu item (task)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // pop up Editable Item (Task) dalam bentuk form
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            let alert = UIAlertController(title: "Edit Item", message: "Edit Your Item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name // menampilkan item (task) sebelumnya
            
            // Tombol Submit ketika ditekan akan close pop up
            // [weak self] Memory Leak Handler
            // Guard untuk menghandle pengisian
            // Jika diisi maka akan ada task baru & jika kosong maka tidak akan ada task baru
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else{
                    return
                }
                
                self?.updateItem(item: item, newName: newName) // update edited item (task)
                
            }))
            
            // Animasi Pop Up Alert
            self.present(alert, animated: true)
        }))
        
        // memunculkan ActionSheet Delete dibawah ketika memilih salah satu item (task)
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item) // delete item yang dipilih
        }))
        
        // Animasi Pop Up Alert
        present(sheet, animated: true)
    }

    // Core Data
    // Get All Items (Task) = fetch item dari database -> reload seluruh data secara Async
    func getAllItems(){
        
        // Harus menggunakan Do {Try & Catch} untuk bisa mengeksekusi pemanggilan method fetch
        do{
            models = try context.fetch(ToDoListItem.fetchRequest())
            
            // Async -> karena perintah reload data harus berjalan di Main Thread agar tetap tersimpan
            DispatchQueue.main.async {
                self.tableView.reloadData() // built-in method reloadData()
            }
        }
        catch{
            // error handling
        }
    }
    
    // Create Item (Task) = Var penampung item baru (konteks) -> tulis judul item -> simpan waktu pembuatan item
    func createItem(name: String){
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date() // built-in method Date()
        
        // Harus menggunakan Do {Try & Catch} untuk bisa mengeksekusi pemanggilan method save
        do{
            try context.save() // built-in method save
            getAllItems() // Reload Data
        }
        catch{
            // error handling
        }
    }
    
    // Delete Item (Task) = Delete Item -> Simpan ke Database -> Reload data setelah di Delete
    func deleteItem(item: ToDoListItem){
        context.delete(item) // built-in method delete
        
        // Harus menggunakan Do {Try & Catch} untuk bisa mengeksekusi pemanggilan method save
        do{
            try context.save() // built-in method save
            getAllItems() // Reload Data
        }
        catch{
            // error handling
        }
    }
    
    // Update Item (Task) = Update Nama Task -> Simpan ke Database -> Reload data setelah di Update
    func updateItem(item: ToDoListItem, newName: String){
        item.name = newName
        
        // Harus menggunakan Do {Try & Catch} untuk bisa mengeksekusi pemanggilan method save
        do{
            try context.save() // built-in method save
            getAllItems() // Reload Data
        }
        catch{
            // error handling
        }
    }
    
}
