//
//  AppDelegate.swift
//  Cognito Test
//
//  Created by Fernando Perez on 9/12/19.
//  Copyright © 2019 Pet Safe. All rights reserved.
//

import UIKit
import CoreData
import AWSCognitoIdentityProvider

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let keyPool = "UserPool"
    
    private var storyBoard: UIStoryboard? = nil
    private var navController: UINavigationController? = nil
    
    private var viewController: ViewController? = nil
    private var pinViewController: PinViewController? = nil
    
    public private(set) var pool: AWSCognitoIdentityUserPool? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let serviceConfiguration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: nil)
        
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(
            clientId: "7edt8ikaftv4ic0n9to5psu8c2",
            clientSecret: nil,
            poolId: "us-east-1_k7HYepu9F")
    
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: userPoolConfiguration, forKey: keyPool)
        AWSServiceManager.default().defaultServiceConfiguration = serviceConfiguration
        
        pool = AWSCognitoIdentityUserPool(forKey: keyPool)
        
        //self.storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Cognito_Test")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate{
    
    func startCustomAuthentication() -> AWSCognitoIdentityCustomAuthentication {
        if (self.navController == nil) {
            self.navController = self.storyBoard?.instantiateInitialViewController() as? UINavigationController
        }
        
        if (self.viewController == nil) {
            self.viewController = self.navController?.viewControllers[0] as? ViewController
        }
        
        /*DispatchQueue.main.async {
            self.navController!.popToRootViewController(animated: true)
            if (!self.navController!.isViewLoaded
                || self.navController!.view.window == nil) {
                self.window?.rootViewController?.present(self.navController!,
                                                         animated: true,
                                                         completion: nil)
            }
        }*/
        let navController = self.window?.rootViewController as? UINavigationController
        return navController?.viewControllers[0] as! ViewController
        //return self.viewController!
    }
}



