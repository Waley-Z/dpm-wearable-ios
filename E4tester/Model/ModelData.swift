//
//  ModelData.swift
//  E4tester
//
//  Created by Waley Zheng on 6/29/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation
import Combine

fileprivate var cancellables = [String : AnyCancellable] ()

public extension Published {
    init(wrappedValue defaultValue: Value, key: String) {
        let value = UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        self.init(initialValue: value)
        cancellables[key] = projectedValue.sink { val in
            UserDefaults.standard.set(val, forKey: key)
        }
    }
}

@MainActor class ModelData: ObservableObject {
    @Published var heartRate: Int = 0
    @Published(key: "fatigueLevel") var fatigueLevel: Int = 0
    
    @Published(key: "loggedIn") var loggedIn: Bool = false
    @Published var nameEntered: Bool = false
    @Published(key: "userCreated") var userCreated: Bool = false
    
    @Published(key: "lastPeerNotification") var lastPeerNotification: Double = 0
    @Published(key: "lastResetDay") var lastResetDay: Int = 0

    var defaultObservations: [Peer.Observation] = []
    
    //    @Published var loggedIn: Bool = true
    //    @Published var nameEntered: Bool = true
    //    @Published var userCreated: Bool = true
    
    @Published var user: User = User()
    @Published var inputs: Inputs = Inputs()
    @Published var crew: [Peer] = []
    
    init() {
        for i in 0...11 {
            defaultObservations.append(Peer.Observation(hour_from_midnight: i, fatigue_level_range: -1 ..< -1))
        }
    }
    
    static func load(completion: @escaping (Result<User, Error>)->Void) {
        DispatchQueue.main.async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success(User()))
                    }
                    return
                }
                let user = try JSONDecoder().decode(User.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(user))
                    print("User information retrieved")
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(user: User, completion: @escaping (Result<Bool, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(user)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // TODO?
    func updatePeer(user_id: Int) async {
        let url = URL(string: Config.API_SERVER + "/api/v1/peer/" + String(user_id) + "/")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print ("error: server error")
                return
            }
            if let mimeType = response.mimeType, mimeType == "application/json",
               let data = data,
               let dataString = String(data: data, encoding: .utf8) {
//                print ("got data: \(dataString)")
                
                if let observationModel = try? JSONDecoder().decode(PeerFatigueResponseModel.self, from: data) {
                    print("success decode observation")
                    
                    let hourRange: Range = 6..<18
                    let observations: [Peer.Observation] = observationModel.observations.filter { hourRange.contains($0.hour_from_midnight)}
                    
                    
                    guard let peerIndex = self.crew.firstIndex(where: {$0.id == user_id}) else {
                        print("error: peer id not found")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.crew[peerIndex].observations = observations
                    }

                } else {
                    print("decode error")
                }
                
            }
        }
        task.resume()
        return
    }
    

    // GET crew
    func updateCrew() async {
        if (self.user.group_id == "") {
            return
        }
        let url = URL(string: Config.API_SERVER + "/api/v1/peer/group/" + self.user.group_id + "/")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print ("error: server error")
                return
            }
            if let mimeType = response.mimeType, mimeType == "application/json",
               let data = data,
               let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
                
                if let decodedModel = try? JSONDecoder().decode(UpdateCrewResponseModel.self, from: data) {
                    print("success")
                    for peer in decodedModel.peers {
//                    for peer in decodedModel.peers where peer.user_id != self.user.user_id {
                                                
                        DispatchQueue.main.async {
                            
                            if let i = self.crew.firstIndex(where: {$0.id == peer.user_id}) {
                                self.crew[i].first_name = peer.first_name
                                self.crew[i].fatigue_level = peer.fatigue_level
                                self.crew[i].last_update = peer.last_update
                                
                            } else {
                                // item could not be found
                                self.crew.append(Peer(
                                    id: peer.user_id,
                                    first_name: peer.first_name,
                                    fatigue_level: peer.fatigue_level,
                                    last_update: peer.last_update,
                                    observations: self.defaultObservations
                                ))
                            }
                            if ( peer.user_id != self.user.user_id && peer.fatigue_level > 70 && !ifLessThanNHours(timestamp: self.lastPeerNotification, hours: 4.0) && ifLessThanNHours(timestamp: Double(peer.last_update), hours: 0.3)){
                                registerPeerNotification(first_name: peer.first_name)
                                self.lastPeerNotification = Date().timeIntervalSince1970
                                print("success: peer notification sent")
                            }
                        }
                        
                        Task{
                            await self.updatePeer(user_id: peer.user_id)
                        }
                        
                    }
                } else {
                    print("decode error")
                    Task{
                        await self.updateCrew()
                    }
                }
                
            }
        }
        task.resume()
        return
    }
    
    // POST query
    func queryName() async {
        struct Request: Codable {
            let first_name: String
            let last_name: String
        }
        
        let request_json = Request(first_name: self.user.first_name, last_name: self.user.last_name)
        guard let encoded_json = try? JSONEncoder().encode(request_json) else {
            print("encode error")
            return
        }
        
        let url = URL(string: Config.API_SERVER + "/api/v1/user/login/")!
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
                print ("error: server error")
                return
            }
            if let mimeType = response.mimeType,
               mimeType == "application/json",
               let data = data,
               let dataString = String(data: data, encoding: .utf8) {
                
                print ("got data: \(dataString)")
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // try to read out a string array
                        if let created = json["created"] as? Bool {
                            print("created: " + String(created))
                            if created {
                                if let first_name = json["first_name"] as? String,
                                   let last_name = json["last_name"] as? String,
                                   let user_id = json["user_id"] as? Int,
                                   let group_id = json["group_id"] as? String,
                                   let age = json["age"] as? Int,
                                   let max_heart_rate = json["max_heart_rate"] as? Int,
                                   let rest_heart_rate = json["rest_heart_rate"] as? Int,
                                   let hrr_cp = json["hrr_cp"] as? Int,
                                   let awc_tot = json["awc_tot"] as? Int,
                                   let k_value = json["k_value"] as? Int
                                {
                                    DispatchQueue.main.async {
                                        
                                        self.user.first_name = first_name
                                        self.user.last_name = last_name
                                        self.user.user_id = user_id
                                        self.user.group_id = group_id
                                        self.user.age = age
                                        self.user.max_heart_rate = max_heart_rate
                                        self.user.rest_heart_rate = rest_heart_rate
                                        self.user.hrr_cp = hrr_cp
                                        self.user.awc_tot = awc_tot
                                        self.user.k_value = k_value
                                        
                                        self.inputs.age = String(age)
                                        self.inputs.rest_heart_rate = String(rest_heart_rate)
                                        self.inputs.hrr_cp = String(hrr_cp)
                                        self.inputs.awc_tot = String(awc_tot)
                                        self.inputs.k_value = String(k_value)
                                        
                                        print("success")
                                        self.userCreated = true
                                    }
                                }
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
                
                
            }
        }
        task.resume()
        return
    }
    
    // POST upload user info
    func uploadUserInfo() async {
        struct Request: Codable {
            let first_name: String
            let last_name: String
            let group_id: String
            let age: Int
            let rest_heart_rate: Int
            let hrr_cp: Int
            let awc_tot: Int
            let k_value: Int
            let user_id: Int
        }
        
        guard let age = Int(trimStr(str: self.inputs.age)),
              let rest_heart_rate = Int(trimStr(str: self.inputs.rest_heart_rate)),
              let hrr_cp = Int(trimStr(str: self.inputs.hrr_cp)),
              let awc_tot = Int(trimStr(str: self.inputs.awc_tot)),
              let k_value = Int(trimStr(str: self.inputs.k_value))
        else {
            return
        }
        
        DispatchQueue.main.async {
            self.user.age = age
            self.user.rest_heart_rate = rest_heart_rate
            self.user.hrr_cp = hrr_cp
            self.user.awc_tot = awc_tot
            self.user.k_value = k_value
        }
        
        let request_json = Request(first_name: self.user.first_name,
                                   last_name: self.user.last_name,
                                   group_id: self.user.group_id,
                                   age: age,
                                   rest_heart_rate: rest_heart_rate,
                                   hrr_cp: hrr_cp,
                                   awc_tot: awc_tot,
                                   k_value: k_value,
                                   user_id: self.user.user_id
        )
        guard let encoded_json = try? JSONEncoder().encode(request_json) else {
            print("encode error")
            return
        }
        
        let url = URL(string: Config.API_SERVER + "/api/v1/user/new/")!
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
                
                print ("got data: \(dataString)")
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // try to read out a string array
                        if let user_id = json["user_id"] as? Int,
                           let max_heart_rate = json["max_heart_rate"] as? Int {
                            DispatchQueue.main.async {
                                self.user.user_id = user_id
                                self.user.max_heart_rate = max_heart_rate
                                
                                print("success")
                                self.userCreated = true
                                self.loggedIn = true
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
                
            }
            
        }
        task.resume()
        return
    }
    
    func uploadActivity(peer_id: Int, if_open:Bool) async {
        struct Request: Codable {
            let user_id: Int
            let peer_id: Int
            let timestamp: Double
            let if_open: Bool
        }
        
        let request_json = Request(user_id: self.user.user_id,
                                   peer_id: peer_id,
                                   timestamp: Date().timeIntervalSince1970,
                                   if_open: if_open
        )
        guard let encoded_json = try? JSONEncoder().encode(request_json) else {
            print("encode error")
            return
        }
        
        let url = URL(string: Config.API_SERVER + "/api/v1/upload/activity/")!
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
                
                print ("got data: \(dataString)")
//                do {
//                    // make sure this JSON is in the format we expect
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        // try to read out a string array
//                        if let user_id = json["user_id"] as? Int,
//                           let max_heart_rate = json["max_heart_rate"] as? Int {
//                            DispatchQueue.main.async {
//                                self.user.user_id = user_id
//                                self.user.max_heart_rate = max_heart_rate
//
//                                print("success")
//                                self.userCreated = true
//                                self.loggedIn = true
//                            }
//                        }
//                    }
//                } catch let error as NSError {
//                    print("Failed to load: \(error.localizedDescription)")
//                }
                
            }
            
        }
        task.resume()
        return
    }
}
