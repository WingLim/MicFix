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
    if args.count == 2 && args[1] == "version" {
        print(version)
    } else {
        MicFix().start()
        RunLoop.current.run()
    }
}

start()
