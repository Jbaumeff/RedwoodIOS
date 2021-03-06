//
//  WalkBusViewController.swift
//  SpartaNow
//
//  Created by Jeffry Baum on 3/28/15.
//  Copyright (c) 2015 Jeffry Baum. All rights reserved.
//

import UIKit

class WalkBusViewController: UIViewController, NSURLConnectionDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topDuration: UILabel!
    @IBOutlet weak var topArrival: UILabel!
    @IBOutlet weak var bottomDuration: UILabel!
    @IBOutlet weak var bottomArrival: UILabel!
    @IBOutlet weak var busLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var walkLabel: UILabel!
    @IBOutlet weak var topDurationLabel: UILabel!
    @IBOutlet weak var topArrivalLabel: UILabel!
    var data = NSMutableData()
    var userLocation: CLLocationCoordinate2D!
    var destinationLocation: CLLocationCoordinate2D!
    var bestColor: UIColor!
    var worstColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bestColor = topView.backgroundColor
        worstColor = bottomView.backgroundColor

        // Do any additional setup after loading the view.
//        startConnection()
    }
    
    func startConnection(){
        let urlPath: String = "http://webdev.cse.msu.edu/~baumjeff/SpartaNow/server.php?slat=\(userLocation.latitude)&slon=\(userLocation.longitude)&dlat=\(destinationLocation.latitude)&dlon=\(destinationLocation.longitude)&MAGIC=CB5D56A21FE65143"
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var err: NSError
        // throwing an error on the line below (can't figure out where the error message is)
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        println(jsonResult)
        updateUI(jsonResult)
    }
    
    func updateUI(json: NSDictionary) {
        if json["status"] as String == "OK" {
            
            let busDuration = json["bus_duration"] as Int
            let walkDuration = json["walk_duration"] as Int
            let busNumber = json["first_bus"] as Int
            bottomDuration.text = "\(busDuration / 60) min \(busDuration % 60) secs"
            topDuration.text = "\(walkDuration / 60) min \(walkDuration % 60) secs"
            busLabel.text = "Bus #\(busNumber)"
            
            if walkDuration <= busDuration || busNumber == -1 {
                self.view.backgroundColor = bestColor
                topView.backgroundColor = bestColor
                bottomView.backgroundColor = worstColor
            } else {
                self.view.backgroundColor = worstColor
                topView.backgroundColor = worstColor
                bottomView.backgroundColor = bestColor
            }
            
            let dateOne = NSDate()
            let dateTwo = NSDate()
            let busDate = dateOne.dateByAddingTimeInterval(NSTimeInterval(busDuration))
            let walkDate = dateTwo.dateByAddingTimeInterval(NSTimeInterval(walkDuration))
            let calendar = NSCalendar.currentCalendar()
            var components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: busDate)
            var hour = components.hour
            var minutes = components.minute
            bottomArrival.text = formatTime(hour, min: minutes)
            components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: walkDate)
            hour = components.hour
            minutes = components.minute
            topArrival.text = formatTime(hour, min: minutes)
            
            if busNumber == -1 {
                busLabel.text = "No Bus"
                durationLabel.text = ""
                arrivalLabel.text = ""
                bottomArrival.text = ""
                bottomDuration.text = ""
            }

        } else {
            bottomDuration.text = ""
            bottomArrival.text = ""
            arrivalLabel.text = ""
            durationLabel.text = ""
            walkLabel.font = UIFont(name: busLabel.font.fontName, size: 80)
            walkLabel.text = "Try Again"
            busLabel.text = ""
            topDuration.text = ""
            topArrival.text = ""
            topDurationLabel.text = ""
            topArrivalLabel.text = ""
            topArrival.text = ""
            topDuration.text = ""
            topView.backgroundColor = worstColor
            self.view.backgroundColor = worstColor
        }

    }
    
    func formatTime(var hour: Int, min: Int) -> String {
        let pm = hour > 11 ? "pm" : "am"
        let minute = min < 10 ? "0\(min)" : "\(min)"
        if hour > 12 {
            hour = hour - 12
        }
        if hour == 0 {
            hour = 12
        }
        return "\(hour):\(minute) \(pm)"
    }
}
