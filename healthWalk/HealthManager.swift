//
//  HealthManager.swift
//  healthWalk
//
//  Created by _Ljx on 2019/8/22.
//  Copyright © 2019 _Ljx. All rights reserved.
//

import UIKit
import HealthKit

class HealthManager: NSObject {
    let healthStore: HKHealthStore = HKHealthStore()
    var stepHandle: ((Double)->())?
    //读取权限
    private let typestoRead = Set([HKObjectType.workoutType(), //步行+跑步距离
        HKObjectType.quantityType(forIdentifier: .stepCount)!, //步数
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,  //活动能量
        HKObjectType.quantityType(forIdentifier: .distanceCycling)!,  //  骑车距离
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,  // 体能训练
        HKObjectType.quantityType(forIdentifier: .heartRate)!])  //心率
    //写入权限
    private let typestoShare = Set([HKObjectType.workoutType(), //步行+跑步距离
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceCycling)!,  //活动能量
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!])
    
    override init() {
        super.init()
        getPermissions()
    }
    
    private func getPermissions() {
        healthStore.requestAuthorization(toShare: typestoRead, read: typestoShare) { (success, error) in
            if !success {
                print("Display not allowed")
            }else {
                print("allowed")
            }
        }
    }
    
    //读取数据
    func stepRead() {
        HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        //NSSortDescriptors用来告诉healthStore怎么样将结果排序
        let start = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let stop  = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let now = Date()
        guard let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            fatalError("*** This method should never fail ***")
        }
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var dataCom = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        let endDate = calendar.date(from: dataCom)    //设置查询的截止时间(当前)
        dataCom.hour = 0
        dataCom.minute = 0
        dataCom.second = 0
        let startDate = calendar.date(from: dataCom)    //设置查询的起始时间(当天0点)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
        
        var localSum: Double = 0  //手机写入步数
        var currentDeviceSum: Double = 0  //软件写入步数
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [start, stop]) { (query, results, error) in
            
            guard (results as? [HKQuantitySample]) != nil else {
                print("获取步数error ---> \(String(describing: error?.localizedDescription))")
                return
            }
            for res in results! {
                // res.sourceRevision.source.bundleIdentifier  当前数据来源的BundleId
                // Bundle.main.bundleIdentifier  当前软件的BundleId
                if res.sourceRevision.source.bundleIdentifier == Bundle.main.bundleIdentifier {
                    let _res = res as? HKQuantitySample
                    currentDeviceSum = currentDeviceSum + (_res?.quantity.doubleValue(for: HKUnit.count()))!
                }else {     //手机录入数据
                    let _res = res as? HKQuantitySample
                    localSum = localSum + (_res?.quantity.doubleValue(for: HKUnit.count()))!
                }
                
            }
            print("当前步数  -- \(currentDeviceSum)")
            print("当前步数  -- \(localSum)")
            let allStep = currentDeviceSum + localSum
            DispatchQueue.main.async { [weak self] in
                self?.stepHandle?(allStep)
            }
        }
        healthStore.execute(query )
    }
    
    func stepWirte(nextStep: Double) {
        healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead, completion: { [weak self] (success, error) in
            if !success {
                NSLog("Display not allowed")
            }else {
                
                //写入的时间点
                let now = Date()
                let startDate = Date(timeInterval: -10, since: now)
                let countUnit = HKUnit.count()
                // 写入的步数
                let countUnitQuantity = HKQuantity.init(unit: countUnit, doubleValue: nextStep)
                let countUnitType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
                let stepCountSample = HKQuantitySample.init(type: countUnitType!, quantity: countUnitQuantity, start: startDate, end: now)
                
                self?.healthStore.save(stepCountSample) { (isSuccess, error) in
                    if isSuccess {
                        print("保存成功 ----> \(isSuccess)")
                    }else {
                        print("error -----> \(String(describing: error))")
                    }
                }
                
                self?.stepRead()
            }
        })
    }
    
    func authorizeHealthKit()->Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
}
