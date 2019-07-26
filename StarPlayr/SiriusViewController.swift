//
//  SiriusViewController.swift
//  StarPlayr
//
//  Created by Todd on 4/1/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import UIKit

/*
 
 override func viewWillDisappear(_ animated: Bool) {
 
 if let volume = gSliderVolume {
 gSliderVolume = StreamVolume.value
 UserDefaults.standard.set(volume, forKey: "StreamVolume")
 }
 }
 
 
 override func viewWillAppear(_ animated: Bool) {
 
 var volume = Float(1.0)
 let volKey = UserDefaults.standard.object(forKey: "StreamVolume") != nil
 
 if volKey {
 volume = UserDefaults.standard.float(forKey: "StreamVolume")
 } else {
 volume = Float(1.0)
 }
 
 */
class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
}
//UIGestureRecognizerDelegate
class SiriusViewController: UITableViewController {
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 60.0
        tableView.separatorColor = UIColor.black
        tableView.allowsSelection = true
        self.clearsSelectionOnViewWillAppear = false
        tableView.sectionIndexBackgroundColor = UIColor.red
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        KeepTableCellUpToDate()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSelected {
            cell.accessoryType = .disclosureIndicator
            cell.accessibilityLabel = "Channels"
            cell.accessibilityHint = "Grouped by Category"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
            cell.textLabel?.textColor = UIColor(displayP3Red: 0 / 255, green: 128 / 255, blue: 255 / 255, alpha: 0.875)
            cell.backgroundColor = UIColor(displayP3Red: 30 / 255, green: 32 / 255, blue: 34 / 255, alpha: 1.0)
        } else {
            cell.textLabel?.font =  UIFont.systemFont(ofSize: 25)
            cell.accessoryType = .none
            cell.accessibilityLabel = .none
            cell.accessibilityHint = .none
            cell.backgroundColor = .none
        }
    }
    
    func KeepTableCellUpToDate() {
        let selectredRows = self.tableView.indexPathsForSelectedRows
        self.tableView.reloadData()
        selectredRows?.forEach({ (selectedRow) in
            self.tableView.selectRow(at: selectedRow, animated: true, scrollPosition: .none)
        })
    }
    
    //Number of Sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    //Sections
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return MusicCategories.count
        } else if section == 1 {
            return TalkCategories.count
        } else if section == 2  {
            return SportsCategories.count
        } else {
            return MiscCategories.count
        }
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        magicTapped()
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Music"
        } else if section == 1 {
            return "Talk"
        } else if section == 2 {
            return "Sports"
        } else {
            return "Other"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.lightGray
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        header.textLabel?.textAlignment = .left
        header.backgroundView?.backgroundColor = UIColor.black // iOS 12
        header.contentView.backgroundColor = UIColor.black //iOS 13
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = MusicCategories[indexPath.row]

        } else if indexPath.section == 1 {
            cell.textLabel?.text = TalkCategories[indexPath.row]
        } else if indexPath.section == 2 {
            cell.textLabel?.text = SportsCategories[indexPath.row]
        } else {
            cell.textLabel?.text = MiscCategories[indexPath.row]
        }
        
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = UIColor(displayP3Red: 41 / 255, green: 42 / 255, blue: 48 / 255, alpha: 1.0)
        return cell
    }
    
    override func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        let text = currentCell.textLabel?.text
        currentCell.textLabel?.textColor = UIColor.lightGray

        categoryTitle = text!
        

    }
}





    
