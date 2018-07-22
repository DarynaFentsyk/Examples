//
//  HealthKitManager.swift
//  HealthManager
//
//  Created by Daryna Fentsyk on 28/05/2018.
//  Copyright © 2018 SW7D. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

final class HealthManager: NSObject {
    
    static let shared = HealthManager()
    let healthStore = HKHealthStore()
    
    enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    private override init() {
        super.init()
    }
    
    // HEALTHKIT AUTHORISATION
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        guard let height = HKObjectType.quantityType(forIdentifier: .height),
            let weight = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let sex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let birthday = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
            else {
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }
        let healthKitTypesToRead: Set<HKObjectType> = [height, weight, sex, birthday]
        
        HKHealthStore().requestAuthorization(toShare: nil,
                                             read: healthKitTypesToRead) { (success, error) in
                                                completion(success, error)
        }
    }
    
    //GETTING USER HEIGHT
    func getUserHeight(completion: @escaping (Double) -> Void) {
        let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, result, error) in
            guard let result = result?.first as? HKQuantitySample else {
                print("An error occured fetching the user's height. The error was: \(String(describing: error?.localizedDescription))")
                return
            }
            completion(result.quantity.doubleValue(for: HKUnit.meter())*100)
        }
        healthStore.execute(query)
    }
    
    //GETTING USER WEIGHT
    func getUserWeight(completion: @escaping (Double) -> Void) {
        let weightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, result, error) in
            guard let result = result?.first as? HKQuantitySample else {
                print("An error occured fetching the user's weight. The error was: \(String(describing: error?.localizedDescription))")
                return
            }
            completion(result.quantity.doubleValue(for: HKUnit.gram())/1000)
        }
        healthStore.execute(query)
    }
    
    //GETTING USER BMI
    func getUserBmi(completion: @escaping (Double) -> Void) {
        let bmiType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMassIndex)!
        let query = HKSampleQuery(sampleType: bmiType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, result, error) in
            guard let result = result?.first as? HKQuantitySample else {
                print("An error occured fetching the user's BMI. The error was: \(String(describing: error?.localizedDescription))")
                return
            }
            completion(result.quantity.doubleValue(for: HKUnit.meter()))
        }
        healthStore.execute(query)
    }
    
    //GETTING USER SEX AND AGE
    func getBiologicalSex() throws -> HKBiologicalSex{
        
        let healthKitStore = HKHealthStore()
        
        do {
            let biologicalSex = try healthKitStore.biologicalSex()
            let unwrappedBiologicalSex = biologicalSex.biologicalSex
            return (unwrappedBiologicalSex)
        }
    }
    
    func getSexFromBiologicalSex(type: HKBiologicalSex) -> String {
        switch type {
        case .notSet: return "Not Set"
        case .female: return "Female"
        case .male: return "Male"
        case .other: return "Other"
        }
    }
    
    func getBirthday() throws -> DateComponents{
        let healthKitStore = HKHealthStore()
        do {
            let birthdayComponents = try healthKitStore.dateOfBirthComponents()
            let unwrappedBirthday = birthdayComponents.date
            print(birthdayComponents)
            print(unwrappedBirthday!)
            return (birthdayComponents)
        }
    }
    
    func getAge(birthday: Date) -> Int {
        let today = Date()
        let calendar = Calendar.current
        let todayDateComponents = calendar.dateComponents([.year], from: today)
        let birthdayComponents = calendar.dateComponents([.year], from: birthday)
        let thisYear = todayDateComponents.year!
        let age = thisYear - birthdayComponents.year!
        return age
    }
}

