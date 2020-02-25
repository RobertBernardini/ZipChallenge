
//
//  DataRepository.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

// Data Service Protocol
protocol DataRepository {
    func fetchStocks() -> [Stock]
    func save(_ stocks: [StockPersistable])
}

// Concrete class that implements the Data Service protocol.
// This class is used to perform any data service functions related to Core Data and the File System.
// Fecthing from Core Data is performed on the Main Context as it will be used to update the UI.
// Saving to and deleting data from Core Data is performed on a Background Context so as not to block the Main UI Thread.
// This class also encapsulates obtaining and saving the Core Data contexts eliminating the need to call the App Delegate.
class ZipDataRepository: DataRepository {
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ZipChallenge")
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error \(error), \(error.userInfo)")
        })
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    private var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    private var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
        
    func fetchStocks() -> [Stock] {
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        let dateSort = NSSortDescriptor(key: "symbol", ascending: true)
        fetchRequest.sortDescriptors = [dateSort]
        guard let stocks = try? mainContext.fetch(fetchRequest) else { return [] }
        return stocks
    }
    
    func save(_ stocks: [StockPersistable]) {
            let context = backgroundContext
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            context.undoManager = nil
            context.performAndWait {
                stocks.forEach { (stockPersistable) in
                    // Fetch and update the already saved Stock entity otherwise insert a new entitiy.
                    let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "symbol == %@", stockPersistable.symbol)
                    guard let stock = try? context.fetch(fetchRequest).first else {
                        let newStock = Stock(context: context)
                        newStock.update(with: stockPersistable)
                        return
                    }
                    stock.update(with: stockPersistable)
                }
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        print("Save error")
                    }
                    context.reset()
                }
                print("Save success")
            }
    }
}
