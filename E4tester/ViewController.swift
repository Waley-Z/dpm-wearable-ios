//
//  ViewController.swift
//  E4 tester
//

import UIKit

class ViewController: UITableViewController {
    
    
    static let EMPATICA_API_KEY = "7022b7ea8fea4c608b594a828a5c7ad3"
    
    
    private var devices: [EmpaticaDeviceManager] = []
    
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
            
            EmpaticaAPI.authenticate(withAPIKey: ViewController.EMPATICA_API_KEY) { (status, message) in
                
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

func startLoad() {
    let url = URL(string: "http://192.168.31.235:8080")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print ("error: \(error)")
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
            print ("error: server error")
            return
        }
        if let mimeType = httpResponse.mimeType, mimeType == "text/html",
            let data = data,
            let string = String(data: data, encoding: .utf8) {
            print("success")
            DispatchQueue.main.async {
                print(string)
            }
        }
    }
    task.resume()
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
      
        print("start networking")
        startLoad()
//        struct Order: Codable {
//            let customerId: String
//            let items: [String]
//        }
//
//        let order = Order(customerId: "12345",
//                          items: ["Cheese pizza", "Diet soda"])
//        guard let uploadData = try? JSONEncoder().encode(order) else {
//            return
//        }
//
//        //
//
//        let url = URL(string: "http://127.0.0.1:5000")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        //
//
//        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
//            if let error = error {
//                print ("error: \(error)")
//                return
//            }
//            guard let response = response as? HTTPURLResponse,
//                (200...299).contains(response.statusCode) else {
//                print ("server error")
//                return
//            }
//            if let mimeType = response.mimeType,
//                mimeType == "application/json",
//                let data = data,
//                let dataString = String(data: data, encoding: .utf8) {
//                print ("got data: \(dataString)")
//            }
//        }
//        task.resume()

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
        let date = Date(timeIntervalSince1970: timestamp)

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter.dateFormat = "HH:mm:ss" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        print("\(device.serialNumber!) \(strDate) TEMP { \(temp) }")
    }
    
    func didReceiveAccelerationX(_ x: Int8, y: Int8, z: Int8, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
        print("\(device.serialNumber!) ACC > {x: \(x), y: \(y), z: \(z)}")
    }
    
    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
        print("\(device.serialNumber!) IBI { \(ibi) }")
    }
    
    func didReceiveTag(atTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
        print("\(device.serialNumber!) TAG received { \(timestamp) }")
    }
    
    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
        print("\(device.serialNumber!) GSR { \(abs(gsr)) }")
        
        self.updateValue(device: device, string: "\(String(format: "%.2f", abs(gsr))) µS")
    }
    
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
