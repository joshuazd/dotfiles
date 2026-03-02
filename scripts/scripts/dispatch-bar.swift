// dispatch-bar.swift — native macOS menu bar item for dispatch-from-chrome
//
// Compile once:
//   swiftc ~/scripts/dispatch-bar.swift -o ~/scripts/dispatch-bar
//
// Run (stays in menu bar until quit):
//   ~/scripts/dispatch-bar &
//
// Auto-start on login via LaunchAgent:
//   1. Create ~/Library/LaunchAgents/com.user.dispatch-bar.plist (see below)
//   2. launchctl load ~/Library/LaunchAgents/com.user.dispatch-bar.plist
//
// LaunchAgent plist content:
// <?xml version="1.0" encoding="UTF-8"?>
// <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
//     "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// <plist version="1.0"><dict>
//   <key>Label</key>       <string>com.user.dispatch-bar</string>
//   <key>ProgramArguments</key>
//   <array><string>/Users/joshua.zink-duda/scripts/dispatch-bar</string></array>
//   <key>RunAtLoad</key>   <true/>
//   <key>KeepAlive</key>   <true/>
// </dict></plist>

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.title = "⚡"
        statusItem.button?.toolTip = "Dispatch Shortcut story or GitHub PR"

        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItem.button?.action = #selector(handleClick)
        statusItem.button?.target = self
    }

    @objc func handleClick() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(
                title: "Quit",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"
            ))
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            dispatchCurrentTab()
        }
    }

    @objc func dispatchCurrentTab() {
        let scriptPath = (NSHomeDirectory() as NSString)
            .appendingPathComponent("scripts/dispatch-from-chrome")
        let task = Process()
        task.executableURL = URL(fileURLWithPath: scriptPath)
        try? task.run()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // no Dock icon
app.run()
