//
//  main.swift
//  MicFix
//
//  Created by WingLim on 2021/5/14.
//

import Foundation

let version = "1.2.0"

func startCommand() {
    MicFix().start()
    RunLoop.current.run()
}

func helpCommand() {
    let help = """
    Fix Headset/Headphone Micphone in Hackintosh with AppleALC.
    
    usage:
        MicFix <command>
    
    commands:
        help    Shows help
        start   Start the MicFix process
        version Prints the version
    """
    print(help)
}

func cli() {
    let args = CommandLine.arguments
    
    if args.count == 1 {
        startCommand()
    } else if args.count == 2 {
        switch args[1] {
        case "version":
            print(version)
        case "help":
            helpCommand()
        case "start":
            startCommand()
        default:
            print("Unknown command")
        }
    } else {
        print("Too many arguments")
    }
}

cli()
