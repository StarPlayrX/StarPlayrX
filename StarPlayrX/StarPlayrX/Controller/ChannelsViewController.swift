///
///  MemberTableViewController.swift
///  SugLoginUser
///
///  Created by Todd Bruss on 12/4/18.
///  Copyright © 2018 SignUpGenius. All rights reserved.
///

import UIKit

var lastchannel = ""
var currentChannelName = ""
var selectedRow : IndexPath? = nil
var lastCategory = "Init Cat"
var globalSearchText = ""

typealias CompletionHandler = (_ success:Bool) -> Void
typealias ImageHandler = (_ image:UIImage?) -> Void
typealias DictionaryHandler = (_ dict:NSDictionary?) -> Void

class ChannelsViewController: UITableViewController,UISearchBarDelegate {
	
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
    override var prefersHomeIndicatorAutoHidden : Bool { return true }

    
    var ChannelsTimer: Timer? = nil

    @IBOutlet var ChannelsTableView: UITableView!
    
    var channelScrollPosIndexPath : IndexPath? = nil
   
    private let Interactive = DispatchQueue(label: "Interactive", qos: .userInteractive )

    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // hides the keyboard.
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let sbtext = searchBar.text {
            if sbtext.count > 0 {
                filterData = coldFilteredData.filter {$0.searchString.lowercased().contains(sbtext.lowercased())}
                globalSearchText = sbtext
            } else {
                globalSearchText = ""
                filterData = coldFilteredData
            }
        	
            UpdateTableView(scrollPosition: .none)

        }
        
    }
    
    private func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    
    //Read Write Cache for the PDT (Artist / Song / Album Art)
    @objc func SPXCacheChannels() {
        Player.shared.updatePDT(completionHandler: { (success) -> Void in
            self.UpdateTableView(scrollPosition: .none)
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .updateChannelsView, object: nil)
    }
    
    func updateFilter() {
        filterData = tableData()
        
        if categoryTitle == Player.shared.allStars {
            coldFilteredData = channelArray.filter {$0.preset} as tableData
        } else if categoryTitle != Player.shared.everything {
            coldFilteredData = channelArray.filter {$0.category == categoryTitle} as tableData
        } else {
            coldFilteredData = channelArray as tableData
        }
        
        //search filter
        if !globalSearchText.isEmpty {
            filterData = coldFilteredData.filter {$0.searchString.lowercased().contains(globalSearchText.lowercased())}
        } else {
            filterData = coldFilteredData
        }
    }
    
    @objc func updateChannelsView() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let searchbartext = searchBar.text {
            if searchbartext.count > 0 {
                globalSearchText = searchbartext
            } else if globalSearchText.count > 0 {
                searchBar.text = globalSearchText
            }
            
        }
        

        
        self.title == categoryTitle ? UpdateTableView(scrollPosition: .none) : UpdateTableView(scrollPosition: .middle) 

        self.title = categoryTitle


        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateTableView), name: .updateChannelsView, object: nil)

    }
        
    
    func SelectMyRow(scrollPosition: UITableView.ScrollPosition ) {
        //Locate the channel is playing
        if !filterData.isEmpty && ( ChannelsTableView.numberOfRows(inSection: 0) == filterData.count ) {
            let index = filterData.firstIndex(where: {$0.channel == currentChannel})
            
            if let i = index {
                SPXSelectRow(myTableView: ChannelsTableView, position: i, scrollPosition: scrollPosition)
            }
        } else if let index = ChannelsTableView.indexPathForSelectedRow {
            ChannelsTableView.deselectRow(at: index, animated: false)
        }
    }
    
    func SPXSelectRow(myTableView: UITableView, position: Int, scrollPosition: UITableView.ScrollPosition) {
        let sizeTable = myTableView.numberOfRows(inSection: 0)
        guard position >= 0 && position < sizeTable else { return }
        let indexPath = IndexPath(row: position, section: 0)
        myTableView.selectRow(at: indexPath, animated: false, scrollPosition: scrollPosition)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        ChannelsTableView.delegate = self
        UpdateTableView()
        
        //self.clearsSelectionOnViewWillAppear = true
    
        searchBar.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0)
        searchBar.barTintColor = UIColor(displayP3Red: 41 / 255, green: 42 / 255, blue: 48 / 255, alpha: 1.0)
        searchBar.delegate = self
        ChannelsTableView.rowHeight = 80
        ChannelsTableView.estimatedRowHeight = 80

        searchBar.sizeToFit()
    }
    
    
    func ChannelsPDT() {
        if ChannelsTimer  == nil {
            ChannelsTimer = Timer.scheduledTimer(timeInterval: 7.5, target: self, selector: #selector(UpdateTableView), userInfo: nil, repeats: true)
        }
    }
    
   
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSelected {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
            cell.contentView.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0) //iOS 13
            cell.setSelected(true, animated: false)
        } else {
            cell.setSelected(false, animated: false)
            cell.contentView.backgroundColor = UIColor(displayP3Red: 41 / 255, green: 42 / 255, blue: 48 / 255, alpha: 1.0) //iOS 12
            cell.accessoryType = .none
        }
    }
    
    
    @objc func UpdateTableView(scrollPosition: UITableView.ScrollPosition = .none) {
        if Player.shared.player.isReady {
            updateFilter()
            ChannelsTableView.reloadData()
            SelectMyRow(scrollPosition: scrollPosition)
        }
    }
   
    
    @objc func pausePlayBack() {
        Player.shared.pause()
    }
    
    
    override func accessibilityPerformMagicTap() -> Bool {
        Player.shared.magicTapped()
        return true
    }
      
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {
		
        if !freshChannels { return }
        
        freshChannels = false
        
        let localCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        localCell.isSelected = true
        localCell.accessoryType = .checkmark
        localCell.tintColor = .systemBlue
        localCell.contentView.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0) //iOS 13

        self.view.endEditing(true)
        
        if let text = localCell.textLabel?.text {
            currentChannelName = text
            
            let previousChannel = currentChannel
            
            if let channel = text.components(separatedBy: " ").first {
                currentChannel = channel
            }
            
            selectedRow = indexPath
            
            if let tvi = tableView.indexPathsForVisibleRows, let scroll = tvi.first {
                
                if !scroll.isEmpty {
                    channelScrollPosIndexPath = tvi.first
                }
            }
            
            lastCategory = categoryTitle
            
            UpdateTableView(scrollPosition: .none)

            DispatchQueue.global().async {
                let this = Player.shared
                currentChannel != previousChannel || this.player.isDead || this.state != .playing ? this.new(.stream) : () //playing
            }
               
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData.count
    }
  
    
    //Display the channels view
    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell", for: indexPath)
        
        if filterData.count > indexPath.row &&
            filterData[indexPath.row].channel.count > 0 {
            
            cell.separatorInset = UIEdgeInsets.zero
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets.zero
            cell.textLabel?.text = filterData[indexPath.row].channel
            cell.textLabel?.attributedText = filterData[indexPath.row].title
            cell.detailTextLabel?.attributedText = filterData[indexPath.row].detail
            cell.imageView?.image = filterData[indexPath.row].image
            cell.detailTextLabel?.numberOfLines = 2
        }
        
        return cell
    }
    
}



