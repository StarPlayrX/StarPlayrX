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

    //var channelScrollPosIndexPath : IndexPath? = nil
    let g = Global.obj
    let p = Player.shared
    
    
    private let Interactive = DispatchQueue(label: "Interactive", qos: .userInteractive )

    @IBOutlet weak var ChannelsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // hides the keyboard.
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let sbtext = searchBar.text else { return }
        
        if sbtext.count > 0 {
            g.FilterData = g.ColdFilteredData?.filter {$0.searchString.lowercased().contains(sbtext.lowercased())}
            g.SearchText = sbtext
        } else {
            g.SearchText = ""
            g.FilterData = g.ColdFilteredData
        }
        
        UpdateTableView(scrollPosition: .none)
        
    }
    
    private func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    
    //Read Write Cache for the PDT (Artist / Song / Album Art)
    @objc func SPXCacheChannels() {
        p.updatePDT(completionHandler: { (success) -> Void in
            self.UpdateTableView(scrollPosition: .none)
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .updateChannelsView, object: nil)

        g.FilterData = nil
        g.ColdFilteredData = nil
        
        ChannelsTableView.removeFromSuperview()
        ChannelsTableView.reloadData()
    }
    
    
    func updateFilter() {
        g.FilterData = nil
        
        if g.categoryTitle == p.allStars {
            g.ColdFilteredData = g.ChannelArray.filter {$0.preset} as tableData
        } else if g.categoryTitle != p.everything {
            g.ColdFilteredData = g.ChannelArray.filter {$0.category == g.categoryTitle} as tableData
        } else {
            g.ColdFilteredData = g.ChannelArray as tableData
        }
        
        //search filter
        if !g.SearchText.isEmpty {
            g.FilterData = g.ColdFilteredData?.filter {$0.searchString.lowercased().contains(g.SearchText.lowercased())}
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
        guard let filterdata = g.FilterData else { return }
        
        //Locate the channel is playing
        if !filterdata.isEmpty && ( ChannelsTableView.numberOfRows(inSection: 0) == filterdata.count ) {
            let index = filterdata.firstIndex(where: {$0.channel == g.currentChannel})
            
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
        updateFilter()
        ChannelsTableView.reloadData()
        SelectMyRow(scrollPosition: scrollPosition)
    }
   
    
    @objc func pausePlayBack() {
        p.pause()
    }
    
    
    override func accessibilityPerformMagicTap() -> Bool {
        p.magicTapped()
        return true
    }
      
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let cell = tableView.cellForRow(at: indexPath) as UITableViewCell?,
            let text = cell.textLabel?.text,
            let channel = text.components(separatedBy: " ").first
            else { return }
        
        cell.isSelected = true
        cell.accessoryType = .checkmark
        cell.tintColor = .systemBlue
        cell.contentView.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0) //iOS 13

        let previousChannel = g.currentChannel
        
        g.currentChannelName = text
        g.currentChannel = channel
        g.SelectedRow = indexPath
        
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
            let doit = self.g.currentChannel != previousChannel || self.p.player.isDead || self.p.state != .playing
            doit ? self.p.new(.stream) : () //playing
            doit || !iPad ? self.performSegue(withIdentifier: "playerViewSegue", sender: cell) : ()
        }
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let filterdata = g.FilterData else { return 0 }
        return filterdata.count
    }
  	
    
    //Display the channels view
    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let filterdata = g.FilterData else { return UITableViewCell() }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell", for: indexPath)
        
        if filterdata.count > indexPath.row &&
            filterdata[indexPath.row].channel.count > 0 {
            
            cell.separatorInset = UIEdgeInsets.zero
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets.zero
            
            let fdr = filterdata[indexPath.row] //filter data row reference
            
            cell.textLabel?.text = fdr.channel
            cell.textLabel?.attributedText = fdr.title
            cell.detailTextLabel?.attributedText = fdr.detail
            cell.imageView?.image = fdr.image
            cell.detailTextLabel?.numberOfLines = 2
        }
        
        return cell
    }
    
}



