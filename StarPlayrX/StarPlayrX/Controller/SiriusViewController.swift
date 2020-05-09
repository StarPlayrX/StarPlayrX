//
//  SiriusViewController.swift
//  StarPlayr
//
//  Created by Todd on 4/1/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import UIKit
import AVKit

class SiriusViewController: UITableViewController {
    var pdtTimer: Timer? = nil
    
    let g = Global.obj
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
    override var prefersHomeIndicatorAutoHidden : Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        g.navBarWidth  = self.navigationController!.navigationBar.frame.width
        g.tabBarHeight = self.tabBarController!.tabBar.frame.height
        
        self.tableView.rowHeight = 60.0
        tableView.separatorColor = UIColor.black
        tableView.allowsSelection = true
        self.clearsSelectionOnViewWillAppear = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: .gotRouteChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: .gotSessionInterruption, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(networkInterruption(_:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
        
        restartPDT()

    }
    
    @objc func networkInterruption(_ notification: Notification) {
        //if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error?
        
        DispatchQueue.global(qos: .default).async {
            if Player.shared.state == .playing {
                Player.shared.pause()
                Player.shared.state = PlayerState.interrupted
                while (!Network.ability.networkIsConnected) { usleep(250000) } //hold
                DispatchQueue.main.async { Player.shared.new(.stream) }
            }
        }
        
    }
    
    @objc func handleRouteChange(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let checkHeadPhones = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
        }
        
        switch checkHeadPhones {
            case .newDeviceAvailable: // New device found.
                let session = AVAudioSession.sharedInstance()
                let startHeadPhones = hasHeadphones(in: session.currentRoute)
                
                if Player.shared.player.rate == 0 && startHeadPhones {
                    Player.shared.playX()
            }
            
            case .oldDeviceUnavailable: // Old device removed.
                if let previousRoute =
                    userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                    let stopHeadphones = hasHeadphones(in: previousRoute)
                    
                    if Player.shared.player.rate == 1 && stopHeadphones {
                        Player.shared.pause()
                    }
            }
            
            default: ()
        }
    }
    
    func hasHeadphones(in audio: AVAudioSessionRouteDescription) -> Bool {
        return audio.outputs.first?.portType == .headphones
    }
    
    
    @objc func handleInterruption(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            print("Interruption began, take appropriate actions")
            NotificationCenter.default.post(name: .didUpdatePause, object: nil)
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                    
                    print("Interruption Ended - playback should resume")
                    
                    Player.shared.state = PlayerState.paused
                    Player.shared.new(.stream)
                    NotificationCenter.default.post(name: .didUpdatePlay, object: nil)
                    
                } else {
                    print("Interruption Ended - playback should NOT resume")
                    
                    Player.shared.state = PlayerState.interrupted
                    NotificationCenter.default.post(name: .didUpdatePause, object: nil)
                }
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        KeepTableCellUpToDate()
    }
    
    //Read Write Cache for the PDT (Artist / Song / Album Art)
    @objc func SPXCache() {
        if g.Server.isReady {
            Player.shared.updatePDT(completionHandler: { (success) -> Void in
                if success {
                    
                    if let i = self.g.ChannelArray.firstIndex(where: {$0.channel == self.g.currentChannel}) {
                        let item = self.g.ChannelArray[i].largeChannelArtUrl
                        Player.shared.updateDisplay(key: self.g.currentChannel, cache: Player.shared.pdtCache, channelArt: item)
                    }
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .updateChannelsView, object: nil)
                    }
                }
            })
        }
    }
    
    func restartPDT() {
        DispatchQueue.main.async {
            self.pdtTimer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(self.SPXCache), userInfo: nil, repeats: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSelected {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor(displayP3Red: 0 / 255, green: 150 / 255, blue: 255 / 255, alpha: 1.0)
            cell.accessibilityLabel = "Channels"
            cell.accessibilityHint = "Grouped by Category"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
            cell.textLabel?.textColor = UIColor(displayP3Red: 0 / 255, green: 128 / 255, blue: 255 / 255, alpha: 0.875)
            cell.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0) //iOS 12
            cell.contentView.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0) //iOS 13
            
        } else {
            cell.textLabel?.font =  UIFont.systemFont(ofSize: 25)
            cell.accessoryType = .none
            cell.accessibilityLabel = .none
            cell.accessibilityHint = .none
            cell.textLabel?.textColor = UIColor.white
            cell.contentView.backgroundColor = UIColor(displayP3Red: 41 / 255, green: 42 / 255, blue: 48 / 255, alpha: 1.0) //iOS 13
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
        g.MiscCategories.isEmpty ? 4 : 5
    }
    
    
    //Sections
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return g.PopularCategories.count
        } else if section == 1 {
            return g.MusicCategories.count
        } else if section == 2 {
            return g.TalkCategories.count
        } else if section == 3  {
            return g.SportsCategories.count
        } else if section == 4 && !g.MiscCategories.isEmpty {
            return g.MiscCategories.count
        } else {
            return 0
        }
    }
    
    
    override func accessibilityPerformMagicTap() -> Bool {
        Player.shared.magicTapped()
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Popular"
        } else if section == 1 {
            return "Music"
        } else if section == 2 {
            return "Talk"
        } else if section == 3 {
            return "Sports"
        } else if !g.MiscCategories.isEmpty {
            return "Misc"
        } else {
            return .none
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    
    override func tableView(_ tableView: UITableView,willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.lightGray
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        header.textLabel?.textAlignment = .left
        header.contentView.backgroundColor = UIColor.black //iOS 13
    }
    
    
    //Display Heading and Category TableView
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell", for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = g.PopularCategories[indexPath.row]
        } else if indexPath.section == 1 {
            cell.textLabel?.text = g.MusicCategories[indexPath.row]
        } else if indexPath.section == 2 {
            cell.textLabel?.text = g.TalkCategories[indexPath.row]
        } else if indexPath.section == 3 {
            cell.textLabel?.text = g.SportsCategories[indexPath.row]
        } else if indexPath.section == 4  {
            if !g.MiscCategories.isEmpty {
                cell.textLabel?.text = g.MiscCategories[indexPath.row]
            } 
        }
        
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = UIColor(
            displayP3Red: 41 / 255, green: 42 / 255, blue: 48 / 255, alpha: 1.0)
        return cell
    }
    
    
    override func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        let text = currentCell.textLabel?.text
        
        currentCell.isSelected = true
        currentCell.accessoryType = .checkmark
        currentCell.tintColor = UIColor(displayP3Red: 0 / 255, green: 150 / 255, blue: 255 / 255, alpha: 1.0)
        currentCell.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0) //iOS 12
        currentCell.contentView.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0) //iOS 13
        currentCell.textLabel?.textColor = UIColor.lightGray
        
        g.categoryTitle = text!
    }
}
