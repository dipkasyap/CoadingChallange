//
//  PatientModel.swift
//  Hospital Finder
//
//  Created by Admin on 19/6/20.
//  Copyright © 2020 Devi Pd Ghimire. All rights reserved.
//

import Foundation
import RealmSwift
import Realm


class PatientDBModel: Object {
    //TODO:- id is static for now, need to provide dynamic id based on user info
    @objc dynamic var id = 0
    @objc dynamic var painLevel = 0
    @objc dynamic var hospital: HospitalDBModel?
    @objc dynamic var illness: IllnessDBModel?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(painLevel: Int, hospital: HospitalDBModel, illness: IllnessDBModel) {
        self.init()
        self.painLevel = painLevel
        self.hospital = hospital
        self.illness = illness
    }
    
}

class HospitalDBModel: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    
    convenience init(id: Int, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
    
}

class IllnessDBModel: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    
    convenience init(id: Int, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
    
}

