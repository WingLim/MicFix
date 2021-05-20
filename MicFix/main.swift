//
//  main.swift
//  MicFix
//
//  Created by WingLim on 2021/5/14.
//

import Foundation

let version = "1.1.2"

func start() {
    let args = CommandLine.arguments
    if args.count == 2 {
        if args[1] == "version" {
            print(version)
        } else if args[1] == "help" {
            let help = """
            Fix Headset/Headphone Micphone in Hackintosh with AppleALC.
            usage:
                manual: nohup MicFix &
                brew: brew services start winglim/taps/micfix
            """
            print(help)
        }
    } else {
        MicFix().start()
        RunLoop.current.run()
    }
}

start()
