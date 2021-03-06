//
//  SettingsVC.swift
//  identaxy
//
//  Created by Ailyn Aguirre on 10/20/19.
//  Copyright © 2019 Ailyn Aguirre. All rights reserved.
//

import UIKit
import FirebaseAuth


class SettingsVC: IdentaxyHeader, UITableViewDelegate, UITableViewDataSource {
    
    let emailSegueIdentifier = "emailSegue"
    let passwordSegueIdentifier = "passwordSegue"
    let helpSegueIdentifier = "helpSegue"
    let aboutSegueIdentifier = "aboutSegue"
    
    var delegate: UIViewController!
    
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var logoutButton: PillShapedButton!
    private let settings = SettingAPI.getSettings()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "darkModeCell", for: indexPath) as! SettingsTableViewCell
            cell.textLabel?.font = UIConstants.ROBOTO_REGULAR
            cell.setting = settings[indexPath.row]
            let switchView = UISwitch(frame: .zero)
            // Set the Dark Mode switch to be on/off.
            if(UserDefaults.standard.bool(forKey:"darkModeOn")) {
                // Dark mode is on.
                switchView.setOn(true, animated: true)
            } else {
                switchView.setOn(false, animated: true)
            }
            switchView.tag = indexPath.row // for detect which row switch Changed
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
            return cell
        } else if(indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath) as! SettingsTableViewCell
            cell.textLabel?.font = UIConstants.ROBOTO_REGULAR
            cell.setting = settings[indexPath.row]
            return cell
        } else if(indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "passwordCell", for: indexPath) as! SettingsTableViewCell
            cell.textLabel?.font = UIConstants.ROBOTO_REGULAR
            cell.setting = settings[indexPath.row]
            return cell
        } else if(indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "helpCell", for: indexPath) as! SettingsTableViewCell
            cell.textLabel?.font = UIConstants.ROBOTO_REGULAR
            cell.setting = settings[indexPath.row]
            return cell
        } else if(indexPath.row == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath) as! SettingsTableViewCell
            cell.textLabel?.font = UIConstants.ROBOTO_REGULAR
            cell.setting = settings[indexPath.row]
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingsTableViewCell
    }
    
    // To set dark/light mode.
    @objc func switchChanged(_ sender : UISwitch!) {
        let prevVC = delegate as! ColorMode
        if(sender.isOn) {
            UserDefaults.standard.set(true, forKey:"darkModeOn")
        } else {
            UserDefaults.standard.set(false, forKey:"darkModeOn")
        }
        prevVC.adjustColor()
        self.setColorMode()
    }
    
    override func setColorMode() {
         super.setColorMode()
         super.adjustButtonColor(button: logoutButton)
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setHeaderTitle(title: "Settings")

        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.separatorColor = UIConstants.IDENTAXY_LIGHT_PINK
        
        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        activateintialConstraints()
        
        self.settingsTableView.rowHeight = 50
        self.settingsTableView.separatorColor = UIConstants.IDENTAXY_GRAY
        self.settingsTableView.separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 20)
        view.addSubview(settingsTableView)
        
        settingsTableView.topAnchor.constraint(equalTo:view.topAnchor).isActive = true
        settingsTableView.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        settingsTableView.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
        settingsTableView.bottomAnchor.constraint(equalTo:logoutButton.topAnchor, constant: -10).isActive = true
        settingsTableView.dataSource = self
        
        // Register Static cell names for segue to different VC's
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "settingCell")
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "darkModeCell")
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "emailCell")
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "passwordCell")
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "helpCell")
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "aboutCell")
        //        settingsTableView.alwaysBounceVertical = false  // No scroll
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath), let identifier = cell.reuseIdentifier {
            var segueID = ""
            switch identifier {
            case "emailCell":
                segueID = "emailSegue"
            case "passwordCell":
                segueID = "passwordSegue"
            case "helpCell":
                segueID = "helpSegue"
            case "aboutCell":
                segueID = "aboutSegue"
            default:
                return
            }
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: segueID, sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == emailSegueIdentifier {
            let nextVC = segue.destination as! UpdateEmailVC
            nextVC.delegate = self
            
        } else if segue.identifier == passwordSegueIdentifier {
            let nextVC = segue.destination as! UpdatePasswordVC
            nextVC.delegate = self
            
        } else if segue.identifier == helpSegueIdentifier {
            let nextVC = segue.destination as! HelpSupportVC
            nextVC.delegate = self
            
        } else if segue.identifier == aboutSegueIdentifier {
            let nextVC = segue.destination as! AboutVC
            nextVC.delegate = self
        }
    }
    
    func activateintialConstraints() {
        // setting constraints manually in code. Deacrtivate storyboard stuff.
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // MARK: - Log out button constraints
            logoutButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            logoutButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            logoutButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            logoutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        print("Logging out")
        do {
            try Auth.auth().signOut()
            let landingVC = self.storyboard?.instantiateViewController(withIdentifier: "LandingPageVC") as! LandingPageVC

            var scenes = UIApplication.shared.connectedScenes
            let sceneDel:SceneDelegate = scenes.popFirst()?.delegate as! SceneDelegate
            
            UserDefaults.standard.removeObject(forKey: "firstName")
            UserDefaults.standard.removeObject(forKey: "lastName")
            
            sceneDel.window?.rootViewController = landingVC
        } catch {
            let alertService = AlertService()
            let alertVC = alertService.alert(title: "Error", message: "There was an error signing out.", button: "OK")
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
