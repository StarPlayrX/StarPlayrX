///
///  MemberTableViewController.swift
///  SugLoginUser
///
///  Created by Todd Bruss on 12/4/18.
///  Copyright © 2018 SignUpGenius. All rights reserved.
///

import UIKit

class ChannelsViewController: UITableViewController,UISearchBarDelegate {
	
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
    override var prefersHomeIndicatorAutoHidden : Bool { return true }

    var ChannelsTimer: Timer? = nil
    var channelScrollPosIndexPath : IndexPath? = nil
    let g = Global.obj
    
    private let Interactive = DispatchQueue(label: "Interactive", qos: .userInteractive )

    @IBOutlet weak var ChannelsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // hides the keyboard.
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let sbtext = searchBar.text {
            if sbtext.count > 0 {
                g.FilterData = g.ColdFilteredData.filter {$0.searchString.lowercased().contains(sbtext.lowercased())}
                g.SearchText = sbtext
            } else {
                g.SearchText = ""
                g.FilterData = g.ColdFilteredData
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

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .updateChannelsView, object: nil)

        g.FilterData = tableData()
        g.ColdFilteredData = tableData()
        
        ChannelsTableView.removeFromSuperview()
        ChannelsTableView.reloadData()
    }
    
    func updateFilter() {
        g.FilterData = tableData()
        
        if g.categoryTitle == Player.shared.allStars {
            g.ColdFilteredData = g.ChannelArray.filter {$0.preset} as tableData
        } else if g.categoryTitle != Player.shared.everything {
            g.ColdFilteredData = g.ChannelArray.filter {$0.category == g.categoryTitle} as tableData
        } else {
            g.ColdFilteredData = g.ChannelArray as tableData
        }
        
        //search filter
        if !g.SearchText.isEmpty {
            g.FilterData = g.ColdFilteredData.filter {$0.searchString.lowercased().contains(g.SearchText.lowercased())}
        } else {
            g.FilterData = g.ColdFilteredData
        }
    }
    
    @objc func updateChannelsView() {
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let searchbartext = searchBar.text {
            if searchbartext.count > 0 {
                g.SearchText = searchbartext
            } else if g.SearchText.count > 0 {
                searchBar.text = g.SearchText
            }
            
        }
    
        self.title == g.categoryTitle ? UpdateTableView(scrollPosition: .none) : UpdateTableView(scrollPosition: .middle)
        self.title = g.categoryTitle
        
    }
        
    
    func SelectMyRow(scrollPosition: UITableView.ScrollPosition ) {
        //Locate the channel is playing
        if !g.FilterData.isEmpty && ( ChannelsTableView.numberOfRows(inSection: 0) == g.FilterData.count ) {
            let index = g.FilterData.firstIndex(where: {$0.channel == g.currentChannel})
            
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
      
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateTableView), name: .updateChannelsView, object: nil)

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
        if g.Server.isReady {
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
		
        //if !freshChannels { return }
        
       // freshChannels = false
        
        let localCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        localCell.isSelected = true
        localCell.accessoryType = .checkmark
        localCell.tintColor = .systemBlue
        localCell.contentView.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0) //iOS 13

        //self.view.endEditing(true)
        
        if let text = localCell.textLabel?.text {

            g.currentChannelName = text
            
            let previousChannel = g.currentChannel
            
            if let channel = text.components(separatedBy: " ").first {
                g.currentChannel = channel
            }
        
            g.SelectedRow = indexPath
            
            if let tvi = tableView.indexPathsForVisibleRows, let scroll = tvi.first {
                
                if !scroll.isEmpty {
                    channelScrollPosIndexPath = tvi.first
                }
            }
            
            g.lastCategory = g.categoryTitle
            UpdateTableView(scrollPosition: .none)
            
            let iPad : Bool
            let iPadHeight = self.view.frame.height
            
            switch iPadHeight {
                //iPad Pro 12.9"
                case 1024.0 :
                    iPad = true
                //iPad 11"
                case 834.0 :
                    iPad = true
                //iPad 9"
                case 810.0 :
                    iPad = true
                //iPad 9"
                case 768.0 :
                    iPad = true

                default :
                    iPad = false
            }
            
            DispatchQueue.main.async {
                let this = Player.shared
                let doit = self.g.currentChannel != previousChannel || this.player.isDead || this.state != .playing
                doit ? this.new(.stream) : () //playing
                
                (doit || !iPad) ? (self.performSegue(withIdentifier: "playerViewSegue", sender: localCell)) : ()

            }
            
        }
        
		return
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return g.FilterData.count
    }
  	

    
    //Display the channels view
    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell", for: indexPath)
        
        if g.FilterData.count > indexPath.row &&
            g.FilterData[indexPath.row].channel.count > 0 {
            
            cell.separatorInset = UIEdgeInsets.zero
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets.zero
            
            let fdr = g.FilterData[indexPath.row] //filter data row reference
            
            cell.textLabel?.text = fdr.channel
            cell.textLabel?.attributedText = fdr.title
            cell.detailTextLabel?.attributedText = fdr.detail
            cell.imageView?.image = fdr.image
            cell.detailTextLabel?.numberOfLines = 2
        }
        
        return cell
    }
    
}



