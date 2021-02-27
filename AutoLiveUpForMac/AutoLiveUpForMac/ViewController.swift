//
//  ViewController.swift
//  AutoLiveUpForMac
//
//  Created by Ryan S.Kennedy on 13.02.2021.
//

import Cocoa

class ViewController: NSViewController, NSComboBoxDataSource, NSTextFieldDelegate {

    @IBOutlet weak var myStartButton: NSButton!
    @IBOutlet weak var myStopButton: NSButton!
    @IBOutlet weak var myComboBox: NSComboBox!
    @IBOutlet weak public var myTimerInterval: NSComboBoxCell!
    
    // get a reference to the app delegate
    let appDelegate: AppDelegate? = NSApplication.shared.delegate as? AppDelegate
    
    func getTimerIntervalInSeconds(rawData: String)->Int{
        
        switch(rawData){
        
            case "5 sec (for test's)":
                return 5 // 5 sec - just for test's
                break
        
            case "1 min":
                return 1*60
                break
                
            case "3 min (By Default)":
                return 3*60
                break
                
            case "5 min":
                return 5*60
                break
                
            case "10 min":
                return 10*60
                break
                
            case "15 min":
                return 15*60
                break
    
            case "30 min":
                return 30*60
                break
                
            case "1 hour":
                return 1*60*60
                break
                
            case "2 hour":
                return 2*60*60
                break
                
            case "3 hour":
                return 3*60*60
                break
                
            default:
                return 3*60 // 3 minutes by default
                break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        myComboBox.selectItem(at: 0)
        myTimerInterval.selectItem(at: 2)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        appDelegate?.reConstructMenu(sMonitoring: appDelegate!.statusMonitoring, sVisibility: false, aAvailability: appDelegate!.actionAvailability)
    }
    
    @IBAction func myTimerIntervalChanged(_ sender: Any) {
        appDelegate!.myTimerInterval = getTimerIntervalInSeconds(rawData: myTimerInterval.stringValue)
    }
    
    
    @IBAction func myKeyCombinationChanged(_ sender: Any) {
        appDelegate!.selection = appDelegate!.availableKeys.firstIndex(where: { (KeyCombinationDictionary) -> Bool in
            KeyCombinationDictionary.keyTitle == myComboBox.stringValue
        })!
    }
    
    @IBAction func ButtonStart(_ sender: Any) {
        myStartButton.isEnabled = false
        myComboBox.isEnabled = false
        myTimerInterval.isEnabled = false
        myStopButton.isEnabled = true
        
        appDelegate?.reConstructMenu(sMonitoring: true, sVisibility: appDelegate!.myStatusVisibility, aAvailability: appDelegate!.actionAvailability)
        
        print("Do Start from UI...")
        
        if !appDelegate!.trusted {
            print("Access Not Enabled")
        } else {
            DispatchQueue.background(background: {
                // do something in background
                self.appDelegate!.snarfKeys()
            }, completion:{
                // when background job finished, do something in main thread
            })
        }
        
        self.appDelegate!.createTimer(timeInterval: Double(self.appDelegate!.timerInterval))
        
        self.appDelegate!.myState.isRun = true
    }
    
    @IBAction func ButtonStop(_ sender: Any) {
        myStartButton.isEnabled = true
        myComboBox.isEnabled = true
        myTimerInterval.isEnabled = true
        myStopButton.isEnabled = false
        
        appDelegate?.reConstructMenu(sMonitoring: false, sVisibility: appDelegate!.myStatusVisibility, aAvailability: appDelegate!.actionAvailability)
        
        print("Do Stop from UI...")
        
        self.appDelegate!.myState.isRun = false
        self.appDelegate!.cancelTimer()
    }
}

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}
