//
//  DetailContactViewController.swift
//  EasyCall
//
//  Created by formation 8 on 25/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit
import FontAwesome_swift
import SkyFloatingLabelTextField
import CoreData

class DetailContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate {

    var contact : Contact!
    var fetchedResultController: NSFetchedResultsController<User>?
    var user : User!
    
    var alertConfirmDelete: UIAlertController!
    var alertNoConnection: UIAlertController!
    var profilePicker: UIPickerView!
    var pickerData: [String] = [String]()
    var isEditable: Bool = false
    var isEditMode : Bool = false
    var valueSelected : String?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewGravatar: UIImageView!
    
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    
    @IBOutlet weak var profileTextField: UITextField!
    @IBOutlet weak var skyFloatingTextFieldFirstName: SkyFloatingLabelTextField!
   
    @IBOutlet weak var skyFloatingTextFieldLastName: SkyFloatingLabelTextField!
    
    @IBOutlet weak var skyFloatingTextFieldPhone: SkyFloatingLabelTextField!
    
    
    @IBOutlet weak var skyFloatingTextFieldMail: SkyFloatingLabelTextField!
    

    
    @IBOutlet weak var labelEmergency: UILabel!
    @IBOutlet weak var switchEmergency: UISwitch!
    
    @IBOutlet weak var buttonPhone: UIButton!
    @IBOutlet weak var buttonMail: UIButton!
    @IBOutlet weak var buttonSMS: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicker = UIPickerView()
        profilePicker.delegate = self
        profileTextField.inputView = profilePicker
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        self.navigationItem.title = "Détail du contact"
        
        imageViewGravatar.image = UIImage.fontAwesomeIcon(name: .userAlt, style: .solid, textColor: .blue, size: CGSize(width: 200, height: 200))
        
        buttonDelete.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
        buttonDelete.setTitle(String.fontAwesomeIcon(name: .trashAlt), for: .normal)
        
        buttonEdit.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
        buttonEdit.setTitle(String.fontAwesomeIcon(name: .pencilAlt), for: .normal)
        
        buttonSMS.titleLabel?.font = UIFont.fontAwesome(ofSize: 60, style: .solid)
        buttonSMS.setTitle(String.fontAwesomeIcon(name: .sms), for: .normal)
        
        buttonMail.titleLabel?.font = UIFont.fontAwesome(ofSize: 60, style: .solid)
        buttonMail.setTitle(String.fontAwesomeIcon(name: .envelope), for: .normal)
        
        buttonPhone.titleLabel?.font = UIFont.fontAwesome(ofSize: 60, style: .solid)
        buttonPhone.setTitle(String.fontAwesomeIcon(name: .phoneSquare), for: .normal)
        
        skyFloatingTextFieldFirstName.text = contact.firstName
        skyFloatingTextFieldFirstName.title = "Prénom"
        
        skyFloatingTextFieldLastName.text = contact.lastName
        skyFloatingTextFieldLastName.title = "Nom de famille"
        
        skyFloatingTextFieldPhone.text = contact.phone
        skyFloatingTextFieldPhone.title = "Numéro de téléphone"
        
        skyFloatingTextFieldMail.text = contact.email
        skyFloatingTextFieldMail.title = "Mail"
        
       
        
        skyFloatingTextFieldFirstName.delegate = self
        skyFloatingTextFieldLastName.delegate = self
        
        profilePicker.delegate = self
        profilePicker.dataSource = self
        
        labelEmergency.text = "Contact urgent"
        
        skyFloatingTextFieldFirstName.isEnabled = false
        skyFloatingTextFieldLastName.isEnabled = false
        skyFloatingTextFieldPhone.isEnabled = false
        skyFloatingTextFieldMail.isEnabled = false
        profileTextField.isEnabled = false
        
        setupFetchedResultController()
        
        user = fetchedResultController?.object(at: indexPath)
    }
    
    func setupFetchedResultController(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "token", ascending: true)]
        
        let resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        resultController.delegate = self
        
        try? resultController.performFetch()
        
        self.fetchedResultController = resultController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APIClient.instance.getProfiles(onSuccess: { (profiles) in
            self.pickerData = profiles
            DispatchQueue.main.async {
                self.profilePicker.reloadComponent(0)
            }
        }, onError: { (error) in
            let loadProfilesFailedAlert = UIAlertController(title: "Chargement impossible", message: "une erreur inconnue est survenue", preferredStyle: UIAlertController.Style.alert)
            loadProfilesFailedAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(loadProfilesFailedAlert, animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        profileTextField.text = pickerData[row]
        profileTextField.resignFirstResponder()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 20.0
    }
    
    @IBAction func onTapEditButton(_ sender: UIButton) {
        if isEditMode == false {
            isEditMode = true
            skyFloatingTextFieldFirstName.isEnabled = true
            skyFloatingTextFieldLastName.isEnabled = true
            skyFloatingTextFieldPhone.isEnabled = true
            skyFloatingTextFieldMail.isEnabled = true
            profileTextField.isEnabled = true
        }else {
            
            guard let phoneNumber = skyFloatingTextFieldPhone.text else {
                return
            }
            guard let firstName = skyFloatingTextFieldFirstName.text else {
                return
            }
            guard let lastName = skyFloatingTextFieldLastName.text else {
                return
            }
            guard let mail = skyFloatingTextFieldMail.text else {
                return
            }
            
            var emergency = false
            if switchEmergency.isOn {
                emergency = true
            }
            
           /* APIClient.instance.updateContact(token: "token a placer", id: contact.serverID!, phone: phoneNumber!, firstName: firstName, lastName: lastName, email: mail, profile: valueSelected ?? "Famille", gravatar: contact.gravatar, isFamilinkUser: false, isEmergencyUser: emergency, onSuccess: {
                
                
            }) { (Error) in
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Pas de connexion", message: "Vous devez vous connecter à Internet pour obtenir la liste des profiles", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }*/
        }
    }
    
    func displayAlertViewForDeleteButton(){
        alertConfirmDelete = UIAlertController(title: "Suppression du contact!", message: "Etes-vous sûr de vouloir supprimer le contact?", preferredStyle: UIAlertController.Style.alert)
        alertNoConnection = UIAlertController(title: "Pas de connexion", message: "Vous devez être connecté à Internet pour supprimer un contact!", preferredStyle: UIAlertController.Style.alert)
        alertNoConnection.addAction(UIAlertAction(title: "Ok", style: .default))
    }
    
    @IBAction func onTapDeleteButton(_ sender: Any) {
        displayAlertViewForDeleteButton()
        alertConfirmDelete.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            APIClient.instance.deleteContact(token: self.user.token!, id: self.contact.serverID!, onSuccess: {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }) { (Error) in
                DispatchQueue.main.async {
                    self.present(self.alertNoConnection, animated: true, completion: nil)
                }
            }
        }))
        
        alertConfirmDelete.addAction(UIAlertAction(title: "Ne pas supprimer", style: .cancel, handler: { (action: UIAlertAction!) in
            print("suppresion annulée")
        }))
        present(alertConfirmDelete, animated: true, completion: nil)
    }
    
    @IBAction func onTapSMSButton(_ sender: Any) {
        open(scheme: "sms:\(contact.phone!)")
    }
    
    @IBAction func onTapButtonMail(_ sender: Any) {
        open(scheme: "mail:\(contact.email!)")
    }
    @IBAction func onTapCallButton(_ sender: Any) {
        open(scheme: "tel:\(contact.phone!)")
    }
    
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: {
                (success) in
                    print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                if(text.count < 2) {
                    floatingLabelTextField.errorMessage = "3 lettres au moins"
                }
                else {
                    // The error message will only disappear when we reset it to nil or empty string
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
        return true
    }
    
    
    @IBAction func onPhoneEditingChanged(_ sender: SkyFloatingLabelTextField!) {
        if sender.text?.count != 10 {
            sender.errorMessage = "10 chiffres obligatoires"
        }else {
            sender.errorMessage = ""
        }
    }

    @IBAction func onMailEditingChanged(_ sender: SkyFloatingLabelTextField!) {
        if !isValidEmail(testStr: (sender.text)!){
            sender.errorMessage = "Le mail n'est pas valide"
        }else {
            sender.errorMessage = ""
        }
    }
}
