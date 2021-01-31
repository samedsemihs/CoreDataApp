//
//  AddPersonViewController.swift
//  CoreDataApp
//
//  Created by Samed  Semih Sürmeli on 31.01.2021.
//

import UIKit
import CoreData

class AddPersonViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var userPhoneText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var getUserId : UUID?
    var getName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //home dan gelen veri boş değilse verileri getir
        if getName != ""{
           getData()
        }
        
        //Gesture Recognizer ---
        //dokunma algılayıcı tanımla
        let viewGestRec = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        //dokunma algılayıcı ekle
        view.addGestureRecognizer(viewGestRec)
        
        userImage.isUserInteractionEnabled = true
        let imgGestRec = UITapGestureRecognizer(target: self, action: #selector(choosePhotoFromGallery))
        
        userImage.addGestureRecognizer(imgGestRec)
        //Gesture recognizer son ---
        
    }
    
    //ekrandaki boşluğa dokunduğunda klavyeyi kapat
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    //galeriden fotoğraf seç
    @objc func choosePhotoFromGallery(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        //        picker.isEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //uygulama delegasyonu
        let context = appDelegate.persistentContainer.viewContext //container oluştur
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PhoneBook") //PhoneBook tablosundan çek
        let idString = getUserId?.uuidString //home dan gelen id yi stringe çevirdik
        
        fetch.returnsObjectsAsFaults = false
        
        fetch.predicate = NSPredicate(format: "id = %@", idString!) //id yi doğruluyoruz.
        
        do {
        let results = try context.fetch(fetch)
            
            //eğer sonuç varsa
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    
                    if let name = result.value(forKey: "name") as? String{
                        self.userNameText.text = name
                    }
                    
                    if let phone = result.value(forKey: "phone") as? String{
                        self.userPhoneText.text = phone
                    }
                    
                    if let imageData = result.value(forKey: "image") as? Data{
                        self.userImage.image = UIImage(data: imageData)
                    }
                    
                }
            }
        } catch  {
            print("hata")
        }
        
        self.navigationItem.title = getName
        self.saveButton.isHidden = true
    }
    
    //fotoğraf seçme işlemi bittikten sonra
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        userImage.image = info[.originalImage] as? UIImage
        dismiss(animated: true) {
            print("görsel seçildi")
        }
    }
    
    
    @IBAction func kaydet(_ sender: Any) {
        //uygulama
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //taşıyıcı container içerik
        let context = appDelegate.persistentContainer.viewContext
        
        //yeni veri
        let newPerson = NSEntityDescription.insertNewObject(forEntityName: "PhoneBook", into: context)
        //son---
        
        //kaydedilecek veri hazırlanıyor
        newPerson.setValue(UUID(), forKey: "id") //pk
        let data = userImage.image?.jpegData(compressionQuality: 0.5) //binary olarak çeviriyoruz
        newPerson.setValue(data, forKey: "image") //binary gönderiyoruz
        newPerson.setValue(userNameText.text, forKey: "name") //ad soyad
        newPerson.setValue(userPhoneText.text, forKey: "phone") //telefon
        //son---
        
        //hazırlanan veriyi kaydetmeyi dene
        do {
            try context.save()
        } catch {
            print("hata")
        }
        //son---
    
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mesaj"), object : nil)
    }
    
}
