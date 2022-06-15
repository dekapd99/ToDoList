//
//  ViewController.swift
//  ToDoList
//
//  Created by Deka Primatio on 30/05/22.
//

import UIKit

// Tampilan Beranda Aplikasi
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Cast context melalui AppDelegate ke persistentContainer (database)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Tabel dengan UITableView
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    private var models = [ToDoListItem]() // Model List Item (Task) dalam bentuk array
    
    // Load Tampilan Beranda
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CoreData To Do List" // Judul Halaman
        view.addSubview(tableView)
        getAllItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        // Tombol Add Task (+) dengan fungsi dalam bentuk Selector Object (@objc)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    // Custom Pop Up Alert => Klik + -> Muncul Pop Up -> Isi Task -> Submit
    @objc private func didTapAdd(){

        // Forms Task Baru
        let alert = UIAlertController(title: "Task Baru", message: "Masukkan Task Baru", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        // Task Forms Handler: Jika ada input maka tambahkan task tersebut, Jika kosong maka tidak akan ditambahkan
        // [weak self] Memory Leak Handler
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else{
                return
            }
            self?.createItem(name: text) // Buat task dari Input String Nama (optional)
        }))
        present(alert, animated: true) // Pop Up Forms (animasi)
    }
    
    // Fungsi untuk menampilkan banyaknya task yang muncul berdasarkan isi database
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    // Menampilkan Task yang tersimpan ke dalam Baris Cell (satuan)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        
//      // Pengecekan tanggal dan waktu dibuatnya task (uncomment)
        // cell.textLabel?.text = "\(model.name) - \(model.createdAt)"
        
        return cell
    }
    
    // Fungsi Edit Task => klik item -> edit -> pop up form editable -> simpan
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        
        // ActionSheet Edit dibawah ketika memilih salah satu item (task)
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        // ActionSheet Cancel dibawah ketika memilih salah satu item (task)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Pop up Editable Task dalam bentuk Form
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            let alert = UIAlertController(title: "Edit Task", message: "Edit Your Task", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name // menampilkan item (task) sebelumnya
            
            // Update Forms Handler: Jika ada input baru maka akan ada Task akan Terupdate, jika tidak diubah maka tidak akan terupdate
            // [weak self] Memory Leak Handler
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else{
                    return
                }
                self?.updateItem(item: item, newName: newName) // Update edited Task
            }))
            self.present(alert, animated: true) // Pop Up Forms (animasi)
        }))
        
        // ActionSheet Delete dibawah ketika memilih salah satu Task
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item) // Delete item yang dipilih dari Database
        }))
        present(sheet, animated: true) // Pop Up Delete (animasi)
    }

    // Fungsi Core Data
    // Fungsi Get All Items (Task) = fetch item dari database -> reload seluruh data secara di Main Thread
    func getAllItems(){
        // Do & Catch untuk mengeksekusi hasil Fetch Data di Main Thread
        do{
            models = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async { // Reload hasil Fetch di Main Thread
                self.tableView.reloadData() // built-in method reloadData()
            }
        }
        catch{
            print("Gagal Menampilkan Task. Silahkan Coba Lagi") // Tampilkan error jika gagal mengeksekusi di Main Thread
        }
    }
    
    // Fungsi Create Task  = Var penampung item baru -> tulis nama item -> simpan waktu pembuatan item
    func createItem(name: String){
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date() // built-in method Date()
        
        // Do & Catch untuk menyimpan Task Baru di Main Thread
        do{
            try context.save() // built-in method save
            getAllItems() // Tampilkan seluruh Task (termasuk yang terbaru)
        }
        catch{
            print("Gagal Membuat Task. Silahkan Coba Lagi") // Tampilkan error jika gagal mengeksekusi di Main Thread
        }
    }
    
    // Fungsi Delete Task = Delete Item -> Simpan ke Database -> Reload data setelah di Delete
    func deleteItem(item: ToDoListItem){
        context.delete(item) // built-in method delete

        // Do & Catch untuk menghapus salah satu Task di Main Thread
        do{
            try context.save() // built-in method save
            getAllItems() // Tampilkan seluruh Task (termasuk hasil baru setelah ada Task yang baru dihapus)
        }
        catch{
            print("Gagal Menghapus Task. Silahkan Coba Lagi") // Tampilkan error jika gagal mengeksekusi di Main Thread
        }
    }
    
    // Update Task = Update Nama Task -> Simpan ke Database -> Reload data setelah di Update
    func updateItem(item: ToDoListItem, newName: String){
        item.name = newName // Get nama Task yang baru di Update
        
        // Do & Catch untuk update salah satu Task di Main Thread
        do{
            try context.save() // built-in method save
            getAllItems() // Tampilkan seluruh Task (termasuk hasil baru setelah ada Task yang baru diupdate)
        }
        catch{
            print("Gagal Update Task. Silahkan Coba Lagi") // Tampilkan error jika gagal mengeksekusi di Main Thread
        }
    }

}
