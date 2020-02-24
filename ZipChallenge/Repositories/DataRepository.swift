
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
    func loadStocksIntoCache() -> Single<Void>
    func fetchStocks() -> Single<[Stock]>
    func fetchFavorites() -> Single<[Stock]>
    func save(_ stocks: [StockPersistable]) -> Single<Void>
}

// Concrete class that implements the Data Service protocol.
// This class is used to perform any data service functions related to Core Data and the File System.
// Fecthing from Core Data is performed on the Main Context as it will be used to update the UI.
// Saving to and deleting data from Core Data is performed on a Background Context so as not to block the Main UI Thread.
// This class also encapsulates obtaining and saving the Core Data contexts eliminating the need to call the App Delegate.
class ZipDataRepository: DataRepository {
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "StockDatabase")
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
    
    private var cachedStocks: [Stock] = []
    
    func loadStocksIntoCache() -> Single<Void> {
        return Single<Void>.create { [weak self] event -> Disposable in
            let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
            let dateSort = NSSortDescriptor(key: "name", ascending: false)
            fetchRequest.sortDescriptors = [dateSort]
            do {
                let items = try self?.mainContext.fetch(fetchRequest) ?? []
                self?.cachedStocks = items
                event(.success(()))
            } catch {
                event(.error(DataError.fetch(error)))
            }
            return Disposables.create()
        }
    }
    
    func fetchStocks() -> Single<[Stock]> {
        return Single.just(cachedStocks)
    }
    
    func fetchFavorites() -> Single<[Stock]> {
        let favorites = cachedStocks.filter({ $0.isFavorite == true })
        return Single.just(favorites)
    }
    
    func save(_ stocks: [StockPersistable]) -> Single<Void> {
        return Single<Void>.create { [weak self] event -> Disposable in
            guard let context = self?.backgroundContext else {
                print("Save error")
                event(.error(DataError.context))
                return Disposables.create()
            }
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            context.undoManager = nil
            context.performAndWait {
                var savedStocks: [Stock] = []
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
                    savedStocks.append(stock)
                }
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        print("Save error")
                        event(.error(DataError.save(error)))
                    }
                    context.reset()
                }
                print("Save success")
                self?.update(savedStocks)
                event(.success(()))
            }
            return Disposables.create()
        }
    }
    
    private func update(_ stocks: [Stock]) {
        stocks.forEach({ stock in
            if let index = self.cachedStocks.firstIndex(where: { $0.symbol == stock.symbol }) {
                self.cachedStocks[index] = stock
            }
        })
    }
    
//    func resetDatabase() {
//        let context = backgroundContext
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RedditEntity.fetchRequest()
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        batchDeleteRequest.resultType = .resultTypeObjectIDs
//
//        do {
//            let deleteResult = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
//            guard let objectIDs = deleteResult?.result as? [NSManagedObjectID] else {
//                return
//            }
//            let mergeChanges = [NSDeletedObjectsKey: objectIDs]
//            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: mergeChanges, into: [mainContext])
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//    }
}
