//
//  AppDelegate.swift
//  AutoLiveUpForMac
//
//  Created by Ryan S.Kennedy on 13.02.2021.
//

import Cocoa
import SwiftUI
import Combine
import Foundation

struct KeyCombinationDictionary : Hashable , Identifiable {
    var id = UUID()
    var keyName : String = ""
    var keyTitle : String = ""
    var keyCode : UInt16 = 0x00

    var hashValue: Int {
        return keyName.hashValue
    }
}

class MyObject: ObservableObject {
    @Published var isRun: Bool = false
}

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSComboBoxDataSource, NSComboBoxDelegate, NSTextFieldDelegate {
    
    @State static var myTestTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) {_ in }
    
    var statusMonitoring : Bool = false
    var myStatusMonitoring : Bool {
            get { return statusMonitoring }
            set { statusMonitoring = newValue }
        }
    
    var statusVisibility : Bool = true
    var myStatusVisibility : Bool {
            get { return statusVisibility }
            set { statusVisibility = newValue }
        }
    
    var actionAvailability : Bool = true
    var myActionAvailability : Bool {
            get { return actionAvailability }
            set { actionAvailability = newValue }
        }
    
    var timerInterval : Int = 180
    var myTimerInterval : Int {
            get { return timerInterval }
            set { timerInterval = newValue }
        }

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    lazy var viewController = mainWindow.contentViewController as? ViewController
    
    var mainWindow = NSWindow()
    var myState = MyObject()
    var myTimer : Timer? = nil
    var selection : Int = 3
    public var trusted : Bool = false
    
    public let availableKeys : [KeyCombinationDictionary] = [
        KeyCombinationDictionary(keyName: "rbKeyCapsLock", keyTitle: "CapsLock", keyCode: 57),
        KeyCombinationDictionary(keyName: "rbKeyTab", keyTitle: "Tab", keyCode: 48),
        KeyCombinationDictionary(keyName: "rbKeyMacCommand", keyTitle: "Command", keyCode: 55),
        KeyCombinationDictionary(keyName: "rbKeyDown", keyTitle: "KeyDown", keyCode: 125)
    ]
    
    public func snarfKeys() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) {
            // If some key appear we should prevent auto key down...
            var kCode = String($0.keyCode)
            
            print(kCode + " - " + self.getDateTime())
            
            if (self.myState.isRun) {
                self.resetTimer()
            }
        }
    }
    
    func createTimer(timeInterval: Double) {
      if myTimer == nil {
        self.myTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            // Simulate keypress
            let NSKeyCode: UInt16 = self.availableKeys[self.selection].keyCode

            let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: NSKeyCode, keyDown: true)
            keyDownEvent?.flags = CGEventFlags.maskCommand
            keyDownEvent?.post(tap: CGEventTapLocation.cghidEventTap)

            let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: NSKeyCode, keyDown: false)
            keyUpEvent?.flags = CGEventFlags.maskCommand
            keyUpEvent?.post(tap: CGEventTapLocation.cghidEventTap)
            
            print("AutoLiveUpEvent - " + self.getDateTime())
        }
      }
    }
    
    func cancelTimer() {
        myTimer?.invalidate()
        myTimer = nil
    }
    
    func resetTimer() {
        cancelTimer()
        createTimer(timeInterval: Double(self.timerInterval))
    }
    
    func getDateTime()->String {
        // get the current date and time
        let currentDateTime = Date()

        // get the user's calendar
        let userCalendar = Calendar.current

        // choose which date and time components are needed
        let requestedComponents: Set<Calendar.Component> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second,
            .nanosecond
        ]
        
        // get the components
        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)

        return String(dateTimeComponents.day!) + "-" +
            String(dateTimeComponents.month!) + "-" +
            String(dateTimeComponents.year!) + " " +
            String(dateTimeComponents.hour!) + ":" +
            String(dateTimeComponents.minute!) + ":" +
            String(dateTimeComponents.second!) + "." +
            String(dateTimeComponents.nanosecond!)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        mainWindow = NSApplication.shared.windows[2] as! NSWindow
        trusted = AXIsProcessTrusted()
        mainWindow.subtitle = String(self.trusted)
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("AutoLiveUp_logo"))
            button.action = #selector(AppDelegate.doSomething(_:))
        }
        
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func doSomething(_ sender: Any?) {
        // Code for chouse function
        
        if statusMonitoring { stopMonitoring() }
        else { startMonitoring() }
    }
    
    @objc func doSomethingWithWindow(_ sender: Any?) {
        // Code for chouse function
        
        if statusVisibility { hide() }
        else { show() }
    }
    
    func startMonitoring() {
        // Code for start function
        
        reConstructMenu(sMonitoring: true, sVisibility: myStatusVisibility, aAvailability: myActionAvailability)
        
        print("Do Start from Bar...")
        
        if !self.trusted {
            print("Access Not Enabled")
        } else {
            DispatchQueue.background(background: {
                // do something in background
                self.snarfKeys()
            }, completion:{
                // when background job finished, do something in main thread
            })
        }
        
        createTimer(timeInterval: Double(self.timerInterval))
        
        self.myState.isRun = true
        
        viewController?.myStartButton.isEnabled = false
        viewController?.myComboBox.isEnabled = false
        viewController?.myTimerInterval.isEnabled = false
        viewController?.myStopButton.isEnabled = true
    }
    
    func stopMonitoring() {
        // Code for stop function
        
        reConstructMenu(sMonitoring: false, sVisibility: myStatusVisibility, aAvailability: myActionAvailability)
        
        print("Do Stop from Bar...")
        
        self.myState.isRun = false
        cancelTimer()
        
        viewController?.myStartButton.isEnabled = true
        viewController?.myComboBox.isEnabled = true
        viewController?.myTimerInterval.isEnabled = true
        viewController?.myStopButton.isEnabled = false
    }
    
    func hide() {
        mainWindow.close()
        NSApplication.shared.hide(self)
        NSApplication.shared.deactivate()
        
        reConstructMenu(sMonitoring: myStatusMonitoring, sVisibility: false, aAvailability: myActionAvailability)
    }

    func show() {
        mainWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        mainWindow.display()
        
        reConstructMenu(sMonitoring: myStatusMonitoring, sVisibility: true, aAvailability: myActionAvailability)
    }
    
    func reConstructMenu(sMonitoring : Bool, sVisibility : Bool, aAvailability : Bool) {
        myStatusMonitoring = sMonitoring
        myStatusVisibility = sVisibility
        myActionAvailability = aAvailability
        
        constructMenu()
    }
    
    func constructMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: (statusVisibility ? "Hide Window" : "Open Window"), action: #selector(AppDelegate.doSomethingWithWindow(_:)), keyEquivalent: "W"))
        menu.addItem(NSMenuItem.separator())
        let myStartStopMenuItem : NSMenuItem = NSMenuItem(title: (statusMonitoring ? "Stop monitoring" : "Start monitoring"), action: #selector(AppDelegate.doSomething(_:)), keyEquivalent: "S")
        myStartStopMenuItem.isEnabled = myActionAvailability
        menu.addItem(myStartStopMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Exit Application", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "E"))
        menu.addItem(NSMenuItem.separator())

        menu.autoenablesItems = false
        statusItem.menu = menu
    }
}

