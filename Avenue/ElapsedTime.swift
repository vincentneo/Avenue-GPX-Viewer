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
       var tmpTime: TimeInterval = elapsedTime
       //calculate the minutes and hours in elapsed time.

       let hours = UInt32(tmpTime / 3600.0)
       tmpTime -= (TimeInterval(hours) * 3600)

       let minutes = UInt32(tmpTime / 60.0)
       tmpTime -= (TimeInterval(minutes) * 60)

       //calculate the seconds in elapsed time.
       let seconds = UInt32(tmpTime)
       tmpTime -= TimeInterval(seconds)

       //display hours only if >0
       let strHours = hours > 0 ? String(hours) + "h " : ""
       //add the leading zero for minutes, seconds and millseconds and store them as string constants

       let strMinutes = String(minutes)
       let strSeconds = String(seconds)

       //concatenate hours, minutes and seconds
       return "\(strHours)\(strMinutes)min \(strSeconds)s"
    }
    
    /// Calls the delegate (didUpdateElapsedTimeString) to inform there was an update of the elapsed time.
    //@objc func updateElapsedTime() {
   //     self.delegate?.stopWatch(self, didUpdateElapsedTimeString: self.elapsedTimeString)
   // }
}
