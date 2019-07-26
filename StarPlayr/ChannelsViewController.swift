///
///  MemberTableViewController.swift
///  SugLoginUser
///
///  Created by Todd Bruss on 12/4/18.
///  Copyright © 2018 SignUpGenius. All rights reserved.
///

import UIKit

import CameoKit
import MediaPlayer

var screenTimer: Timer? = nil
var pdtTimer: Timer? = nil
var globalSearchText = ""
var lastchannel : String? = ""
var selectedRow : IndexPath? = nil
var lastCategory = "Init Cat"
var currentChannelName = ""
var channelScrollPosIndexPath : IndexPath? = nil

public let PDTqueue = DispatchQueue(label: "PDT", qos: .userInteractive )

class ChannelsViewController: UITableViewController,UISearchBarDelegate {
    private let Interactive = DispatchQueue(label: "Interactive", qos: .userInteractive )
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // hides the keyboard.
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        globalSearchText = searchText
        
        if globalSearchText != "" {
            filterData = coldFilteredData.filter {$0.searchString.lowercased().contains(globalSearchText.lowercased())}
        } else {
            filterData = coldFilteredData
        }
        tableView.reloadData()
    }
    
    private func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = categoryTitle
        
    
        globalSearchText = ""
        
        if let d = data {
            if categoryTitle != "All" {
                coldFilteredData = d.filter {$0.category == categoryTitle} as tableData
            } else {
                coldFilteredData = d as tableData
            }
            
            filterData = coldFilteredData
        }
        
        readFromPDTCache()
        
        if let selectRow = selectedRow {
            if categoryTitle == lastCategory  {
                tableView.selectRow(at: selectRow, animated: false, scrollPosition: .middle)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.rowHeight = 80
        tableView.estimatedRowHeight = 80
  
        self.clearsSelectionOnViewWillAppear = false
       
        searchBar.sizeToFit()
        
        if pdtTimer != nil {
            pdtTimer!.invalidate()
            pdtTimer = nil
        }
        
        pdtTimer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(ChannelsViewController.writeToPDTCache), userInfo: nil, repeats: true)
        //searchBar.tintColor = UIColor(displayP3Red: 0 / 255, green: 128 / 255, blue: 255 / 255, alpha: 1.0)
       // searchBar.barStyle = .default

        //searchBar.inputView?.backgroundColor = UIColor.black
        //searchBar.backgroundColor = UIColor.red
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSelected {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor(displayP3Red: 0 / 255, green: 150 / 255, blue: 255 / 255, alpha: 1.0)
            cell.backgroundColor = UIColor(red: 29/255, green: 30/255, blue: 36/255, alpha: 1.0)
            cell.setSelected(true, animated: false)
        } else {
            cell.setSelected(false, animated: false)
            cell.accessoryType = .none
            cell.backgroundColor = .none
            cell.accessoryType = .none
        }
    }
    
    func KeepTableCellUpToDate() {
        let selectredRows = self.tableView.indexPathsForSelectedRows
        self.tableView.reloadData()
        selectredRows?.forEach({ (selectedRow) in
            self.tableView.selectRow(at: selectedRow, animated: false, scrollPosition: .none)
        })
    }
    
   
    @objc func pausePlayBack() {
        Pause()
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        magicTapped()
        return true
    }
    
    @objc func writeToPDTCache() {
        updatePDT(updateCache: true)
    }
    
    @objc func readFromPDTCache() {
        updatePDT(updateCache: false)
    }
    
    func updatePDT(updateCache: Bool)  {
        /*
        if let starplayr = player {
            if !starplayr.isReady {
                return
            }
        }*/
        
        PDTqueue.async { [weak self] in
            guard let self = self else {return}
        
            var returnData : tableData? = tableData()
            
            returnData = updatePDT2(importData: data!, category: categoryTitle, updateScreen: true, updateCache: updateCache)
          
            if returnData!.count > 0 {
                // data = tableData()
                coldFilteredData = returnData!
                returnData = tableData()
                
                if globalSearchText != "" {
                    filterData = coldFilteredData.filter {$0.searchString.lowercased().contains(globalSearchText.lowercased())}
                } else {
                    filterData = coldFilteredData
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.KeepTableCellUpToDate()
            }
        }
        
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {

        let localCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        localCell.isSelected = true
        localCell.accessoryType = .checkmark
        localCell.tintColor = UIColor(displayP3Red: 0 / 255, green: 150 / 255, blue: 255 / 255, alpha: 1.0)

       // self.view.endEditing(true)
        
        if let text = localCell.textLabel?.text {
            currentChannelName = text
            
            if let channel = text.components(separatedBy: " ").first {
                currentChannel = channel
            }
            
            selectedRow = indexPath
            channelScrollPosIndexPath = tableView.indexPathsForVisibleRows?.first
            lastCategory = categoryTitle
            
        }
       

       readFromPDTCache()

    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData.count
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if filterData.count > indexPath.row && filterData[indexPath.row].channel.count > 0 {
            
            cell.separatorInset = UIEdgeInsets.zero
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets.zero
            cell.textLabel?.text = filterData[indexPath.row].channel
            cell.textLabel?.attributedText = filterData[indexPath.row].title
            cell.detailTextLabel?.attributedText = filterData[indexPath.row].detail
            cell.imageView?.image =  filterData[indexPath.row].image
            cell.detailTextLabel?.numberOfLines = 2
        }
        
        return cell
    }
}



