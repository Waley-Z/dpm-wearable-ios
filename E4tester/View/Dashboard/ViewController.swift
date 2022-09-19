//
//  ViewController.swift
//  E4 tester
//

import UIKit
import SwiftUI

class ViewController: UITableViewController {
    weak var delegate: ViewControllerDelegate?
    
    private var devices: [EmpaticaDeviceManager] = []
    private var serialNum: String = ""
    
    private var user_id: Int = -1
    
    private var heartRates: [Int] = []
    private var lastUpdateTime: Double = 0
    
    private var rest_heart_rate: Int = 60
    private var max_heart_rate: Int = 180
    private var hrr_cp: Int = 16
    private var awc_tot: Int = 200
    private var awc_exp: Int = 0
    
    private var k_value: Int = 1
    
    init(delegate: ViewControllerDelegate, user_id: Int, max_heart_rate: Int, rest_heart_rate: Int, hrr_cp: Int, awc_tot: Int, k_value: Int) {
        super.init(style: .plain)
        self.delegate = delegate
        self.user_id = user_id
        self.max_heart_rate = max_heart_rate
        self.rest_heart_rate = rest_heart_rate
        self.hrr_cp = hrr_cp
        self.awc_tot = awc_tot
        self.k_value = k_value
        print("viewcontroller user_id: \(user_id)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var allDisconnected : Bool {
        return self.devices.reduce(true) { (value, device) -> Bool in
            value && device.deviceStatus == kDeviceStatusDisconnected
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            EmpaticaAPI.authenticate(withAPIKey: Config.EMPATICA_API_KEY) { (status, message) in
                if status {
                    // "Authenticated"
                    DispatchQueue.main.async {
                        self.discover()
                    }
                }
            }
        }
    }
    
    private func discover() {
        EmpaticaAPI.discoverDevices(with: self)
    }
    
    private func disconnect(device: EmpaticaDeviceManager) {
        if device.deviceStatus == kDeviceStatusConnected {
            device.disconnect()
        }
        else if device.deviceStatus == kDeviceStatusConnecting {
            device.cancelConnection()
        }
    }
    
    private func connect(device: EmpaticaDeviceManager) {
        device.connect(with: self)
    }
    
    private func updateValue(device : EmpaticaDeviceManager, string : String = "") {
        
        if let row = self.devices.firstIndex(of: device) {
            
            DispatchQueue.main.async {
                
                for cell in self.tableView.visibleCells {
                    
                    if let cell = cell as? DeviceTableViewCell {
                        
                        if cell.device == device {
                            
                            let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0))
                            
                            if !device.allowed {
                                cell?.detailTextLabel?.text = "NOT ALLOWED"
                                cell?.detailTextLabel?.textColor = UIColor.orange
                            }
                            else if string.count > 0 {
                                cell?.detailTextLabel?.text = "\(self.deviceStatusDisplay(status: device.deviceStatus)) • \(string)"
                                cell?.detailTextLabel?.textColor = UIColor.gray
                            }
                            else {
                                cell?.detailTextLabel?.text = "\(self.deviceStatusDisplay(status: device.deviceStatus))"
                                cell?.detailTextLabel?.textColor = UIColor.gray
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func deviceStatusDisplay(status : DeviceStatus) -> String {
        
        switch status {
            
        case kDeviceStatusDisconnected:
            return "Disconnected"
        case kDeviceStatusConnecting:
            return "Connecting..."
        case kDeviceStatusConnected:
            return "Connected"
        case kDeviceStatusFailedToConnect:
            return "Failed to connect"
        case kDeviceStatusDisconnecting:
            return "Disconnecting..."
        default:
            return "Unknown"
        }
    }
    
    private func restartDiscovery() {
        
        print("restartDiscovery")
        
        guard EmpaticaAPI.status() == kBLEStatusReady else { return }
        
        if self.allDisconnected {
            
            print("restartDiscovery • allDisconnected")
            
            self.discover()
        }
    }
}

protocol ViewControllerDelegate: AnyObject {
    func updateHeartRate(_ viewController: ViewController, heartRate: Int)
    
    func updateFatigueLevel(_ viewController: ViewController, fatigueLevel: Int)
}


// utilities
extension ViewController {
    
    // convert timestamp to date string
    func ts2date(timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter.dateFormat = "HH:mm:ss" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }

    // POST
    func uploadHeartRate(heartRate: Int, timestamp: Double) {
        struct Request: Codable {
            let user_id: Int
            let heart_rate: Int
            let timestamp: Double
        }
        
        let request_json = Request(user_id: self.user_id, heart_rate: heartRate, timestamp: timestamp)
        guard let encoded_json = try? JSONEncoder().encode(request_json) else {
            return
        }
        
        let url = URL(string: Config.API_SERVER + "/api/v1/upload/heart_rate/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: encoded_json) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print ("server error")
                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                
                DispatchQueue.main.async {
                    print ("got data: \(dataString)")
                }
            }
        }
        task.resume()
        return
    }
    
    // POST
    func uploadFatigueLevel(fatigueLevel: Int, timestamp: Double) {
        struct Request: Codable {
            let user_id: Int
            let fatigue_level: Int
            let timestamp: Double
        }
        
        let request_json = Request(user_id: self.user_id, fatigue_level: fatigueLevel, timestamp: timestamp)
        guard let encoded_json = try? JSONEncoder().encode(request_json) else {
            return
        }
        
        let url = URL(string: Config.API_SERVER + "/api/v1/upload/fatigue_level/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: encoded_json) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print ("server error")
                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                
                DispatchQueue.main.async {
                    print ("got data: \(dataString)")
                }
            }
        }
        task.resume()
        return
    }
    
    func assessFatigue() {
        
        print("\(Date().timeIntervalSince1970) start assessing \(self.heartRates.count) heart rate data")
        
        // calculate HRR
        let sum = self.heartRates.reduce(0, +)
        let avgHR = sum / self.heartRates.count // average heartrate within one minute
        let HRR = Int(Double(avgHR - self.rest_heart_rate) / Double(self.max_heart_rate - self.rest_heart_rate) * 100)
        print("avgHR = \(avgHR)")
        print("HRR = \(HRR)")
        
        // assess fatigue
        self.awc_exp = max(self.awc_exp + self.k_value * (HRR - self.hrr_cp), 0)
        let fatigue = Int(Double(self.awc_exp) / Double(self.awc_tot) * 100)
        print("fatigue = \(fatigue)")

        // update UI
        print("fatigue updated")
        delegate?.updateFatigueLevel(self, fatigueLevel: fatigue)
        
        // upload
        uploadFatigueLevel(fatigueLevel: fatigue, timestamp: Date().timeIntervalSince1970)

        self.heartRates = []
        self.lastUpdateTime = Date().timeIntervalSince1970
    }
}

extension ViewController: EmpaticaDelegate {
    
    func didDiscoverDevices(_ devices: [Any]!) {
        
        print("didDiscoverDevices")
        
        if self.allDisconnected {
            
            print("didDiscoverDevices • allDisconnected")
            
            self.devices.removeAll()
            
            self.devices.append(contentsOf: devices as! [EmpaticaDeviceManager])
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                
                if self.allDisconnected {
                    EmpaticaAPI.discoverDevices(with: self)
                }
            }
        }
    }
    
    func didUpdate(_ status: BLEStatus) {
        
        switch status {
        case kBLEStatusReady:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusReady")
            break
        case kBLEStatusScanning:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusScanning")
            break
        case kBLEStatusNotAvailable:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusNotAvailable")
            break
        default:
            print("[didUpdate] status \(status.rawValue)")
        }
    }
}

extension ViewController: EmpaticaDeviceDelegate {
    
    func didReceiveTemperature(_ temp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
//        let strDate = ts2date(timestamp: timestamp)
//        print("\(device.serialNumber!) \(strDate) TEMP { \(temp) }")
//        delegate?.updateFatigueLevel(self, fatigueLevel: Int(temp))
    }
    
    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
        let heartRate = Int(60 / ibi)
        self.heartRates.append(heartRate)
        
        // update UI
        delegate?.updateHeartRate(self, heartRate: heartRate)

        // upload to server
        uploadHeartRate(heartRate: heartRate, timestamp: timestamp)
        
        // check time interval
        if (timestamp - self.lastUpdateTime > 60) {
            assessFatigue()
        }
        
        // print
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter.dateFormat = "HH:mm:ss" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        print("\(device.serialNumber!) \(strDate) IBI { \(ibi) }")
//        print("\(device.serialNumber!) \(timestamp) IBI { \(ibi) }")

    }
    
    //    func didReceiveBVP(_ bvp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
    //
    //        print("\(device.serialNumber!) BVP { \(timestamp) \(bvp) }")
    //    }
    
    
    func didUpdate( _ status: DeviceStatus, forDevice device: EmpaticaDeviceManager!) {
        
        self.updateValue(device: device)
        
        switch status {
            
        case kDeviceStatusDisconnected:
            print("[didUpdate] Disconnected \(device.serialNumber!).")
            self.restartDiscovery()
            break
            
        case kDeviceStatusConnecting:
            print("[didUpdate] Connecting \(device.serialNumber!).")
            break
            
        case kDeviceStatusConnected:
            print("[didUpdate] Connected \(device.serialNumber!).")
            self.lastUpdateTime = Date().timeIntervalSince1970 + 10
            print("init lastUpdateTime to \(self.lastUpdateTime).")
            break
            
        case kDeviceStatusFailedToConnect:
            print("[didUpdate] Failed to connect \(device.serialNumber!).")
            self.restartDiscovery()
            break
            
        case kDeviceStatusDisconnecting:
            print("[didUpdate] Disconnecting \(device.serialNumber!).")
            break
            
        default:
            break
            
        }
    }
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        EmpaticaAPI.cancelDiscovery()
        
        let device = self.devices[indexPath.row]
        
        if device.deviceStatus == kDeviceStatusConnected || device.deviceStatus == kDeviceStatusConnecting {
            
            self.disconnect(device: device)
        }
        else if !device.isFaulty && device.allowed {
            
            self.connect(device: device)
        }
        
        self.updateValue(device: device)
    }
}

extension ViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let device = self.devices[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "device") as? DeviceTableViewCell ?? DeviceTableViewCell(device: device)
        
        cell.device = device
        
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        cell.textLabel?.text = "E4 \(device.serialNumber!)"
        
        cell.alpha = device.isFaulty || !device.allowed ? 0.2 : 1.0
        
        return cell
    }
}

class DeviceTableViewCell : UITableViewCell {
    
    var device : EmpaticaDeviceManager
    
    init(device: EmpaticaDeviceManager) {
        
        self.device = device
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "device")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}
