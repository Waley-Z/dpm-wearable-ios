//
//  ModelData.swift
//  E4tester
//
//  Created by Waley Zheng on 6/29/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation

struct User: Decodable {
    var fullname: String = ""
    var user_id: Int = -1
    var group_id: String = ""
    var age: Int = -1
    var max_heart_rate: Int = -1
    var rest_heart_rate: Int = -1
    var hrr_cp: Int = -1
    var awc_tot: Int = -1
    var k_value: Int = -1
}

struct Inputs {
    var age: String = ""
    var rest_heart_rate: String = ""
    var hrr_cp: String = ""
    var awc_tot: String = ""
    var k_value: String = ""
}

@MainActor class ModelData: ObservableObject {
    @Published var heartRate: Int = 0
    @Published var fatigueLevel: Int = 0
    
    @Published var loggedIn: Bool = false
    @Published var nameEntered: Bool = false
    @Published var userCreated: Bool = false
    
    @Published var user: User = User()
    @Published var inputs: Inputs = Inputs()
    
    
    
    // POST query
    func queryName() async {
        struct Request: Codable {
            let fullname: String
        }
        
        let request_json = Request(fullname: self.user.fullname)
        guard let encoded_json = try? JSONEncoder().encode(request_json) else {
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
                print ("server error")
                return
            }
            if let mimeType = response.mimeType,
               mimeType == "application/json",
               let data = data,
               let dataString = String(data: data, encoding: .utf8) {
                
                DispatchQueue.main.async {
                    print ("got data: \(dataString)")
                    do {
                        // make sure this JSON is in the format we expect
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            // try to read out a string array
                            if let created = json["created"] as? Bool {
                                print("created: " + String(created))
                                if created {
                                    if let fullname = json["fullname"] as? String,
                                       let user_id = json["user_id"] as? Int,
                                       let group_id = json["group_id"] as? String,
                                       let age = json["age"] as? Int,
                                       let max_heart_rate = json["max_heart_rate"] as? Int,
                                       let rest_heart_rate = json["rest_heart_rate"] as? Int,
                                       let hrr_cp = json["hrr_cp"] as? Int,
                                       let awc_tot = json["awc_tot"] as? Int,
                                       let k_value = json["k_value"] as? Int
                                    {
                                        self.user.fullname = fullname
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
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                }
            }
        }
        task.resume()
        return
    }
    
    // POST upload user info
    func uploadUserInfo() async {
        struct Request: Codable {
            let fullname: String
            let group_id: String
            let age: Int
            let rest_heart_rate: Int
            let hrr_cp: Int
            let awc_tot: Int
            let k_value: Int
            let user_id: Int
        }
        
        guard let age = Int(self.inputs.age),
              let rest_heart_rate = Int(self.inputs.rest_heart_rate),
              let hrr_cp = Int(self.inputs.hrr_cp),
              let awc_tot = Int(self.inputs.awc_tot),
              let k_value = Int(self.inputs.k_value)
        else {
            return
        }
        
        self.user.age = age
        self.user.rest_heart_rate = rest_heart_rate
        self.user.hrr_cp = hrr_cp
        self.user.awc_tot = awc_tot
        self.user.k_value = k_value
        
        let request_json = Request(fullname: self.user.fullname,
                                   group_id: self.user.group_id,
                                   age: age,
                                   rest_heart_rate: rest_heart_rate,
                                   hrr_cp: hrr_cp,
                                   awc_tot: awc_tot,
                                   k_value: k_value,
                                   user_id: self.user.user_id
        )
        guard let encoded_json = try? JSONEncoder().encode(request_json) else {
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
                
                DispatchQueue.main.async {
                    print ("got data: \(dataString)")
                    do {
                        // make sure this JSON is in the format we expect
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            // try to read out a string array
                            if let user_id = json["user_id"] as? Int,
                               let max_heart_rate = json["max_heart_rate"] as? Int {
                                self.user.user_id = user_id
                                self.user.max_heart_rate = max_heart_rate
                                
                                print("success")
                                self.userCreated = true
                                self.loggedIn = true
                            }
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                }
            }
        }
        task.resume()
        return
    }
}
