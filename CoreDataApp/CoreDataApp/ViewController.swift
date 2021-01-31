//
//  ViewController.swift
//  CoreDataApp
//
//  Created by Samed  Semih Sürmeli on 31.01.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var personTableView: UITableView!
    
    var names = [String]()
    var userIds = [UUID]()
    
    //segue da gönderilecek isim ve id değerleri
    var selectedID :UUID?
    var selectedName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personTableView.dataSource = self
        personTableView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
        
        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "mesaj"), object: nil)
    }
    
    @objc func getData(){
        
        names.removeAll(keepingCapacity: false)
        userIds.removeAll(keepingCapacity: false)
        
        //tanımlamalar (delegasyonlar)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PhoneBook")
        
        //app hızlandırmak için sonuçları hata gibi döndürmesini engelliyoruz.
        fetch.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetch)
            
            for result in results as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String {
                    self.names.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID {
                    self.userIds.append(id)
                }
                
                self.personTableView.reloadData()
            }
            
        } catch  {
            print("hata")
        }
        
    }
    
    //veri silme işlemi
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PhoneBook")
            let idString = userIds[indexPath.row].uuidString
            
            fetch.predicate = NSPredicate(format: "id = %@",  idString)
            
            do {
                let results = try context.fetch(fetch)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == userIds[indexPath.row]{
                                context.delete(result)
                                names.remove(at: indexPath.row)
                                userIds.remove(at: indexPath.row)
                                self.personTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                                self.personTableView.reloadData()
                                
                                do {
                                    try context.save()
                                } catch  {
                                    print("hata")
                                }
                                break
                            }
                            
                        }
                        
                    }
                }
                
            } catch  {
                print("hata")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        //userIds[indexPath.row].uuidString
        cell.textLabel?.text = names[indexPath.row]
        return cell
    }
    
    @objc func addPerson() {
        selectedName = ""
        performSegue(withIdentifier: "showPerson", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedID = userIds[indexPath.row]
        selectedName = names[indexPath.row]
        performSegue(withIdentifier: "showPerson", sender: nil)
    }
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        print(selectedID!.uuidString)
    //    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPerson" {
            let dest = segue.destination as! AddPersonViewController
            dest.getUserId = selectedID
            dest.getName = selectedName
        }
    }
}

