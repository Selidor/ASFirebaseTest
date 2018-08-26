//
//  AppDelegate.h
//  CiklumFirebaseTest
//
//  Created by Artem Shvets on 24.08.2018.
//  Copyright © 2018 Artem Shvets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

+ (instancetype)sharedInstance;

- (void)saveContext;


@end

