//
//  Extracted from StopWatch.swift of merlos/iOS-Open-GPX-Tracker
//

import Foundation

///
/// This class handles the logic behind a stop watch timer
/// It has two statuses: started or stopped. When started it counts time.
/// when stopped it does not count time.
///
class ElapsedTime {
    
    ///
    /// Returns the elapsed time as a String with the format `MM:SS` or `HhMM:SS`
    ///
    ///  Examples:
    ///    1. if elapsed time is 3 min 30 sec, returns `3 min 30 s`
    ///    2. 3h 40 min 30 sec, returns  `3 h 40 min 20 s`
    ///
    static func getString(from elapsedTime: TimeInterval) -> String {
        if elapsedTime < 0 {
            return "0min 0s"
        }
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) / 60) % 60
        let seconds = Int(elapsedTime) % 60
        
        //display hours only if >0
        let strHours = hours > 0 ? String(hours) + "h " : ""
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(minutes)
        let strSeconds = String(seconds)
        
        //concatenate hours, minutes and seconds
        return "\(strHours)\(strMinutes)min \(strSeconds)s"
    }
}
