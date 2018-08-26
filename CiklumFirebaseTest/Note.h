//
//  Note.h
//  CiklumFirebaseTest
//
//  Created by Artem Shvets on 25.08.2018.
//  Copyright © 2018 Artem Shvets. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <CoreData/CoreData.h>
#import "NoteObject+CoreDataClass.h"


@interface Note : NSObject

@property (nonatomic, strong) NSString* noteID;
@property (nonatomic, strong, readonly) NSString* text;
@property (nonatomic, strong, readonly) NSDate* createDate;
@property (nonatomic) NSTimeInterval receivingDateInterval;//localParam
@property (nonatomic, getter = isSaved) BOOL saved;

- (instancetype)initWithText:(NSString*)text creatDate:(NSDate*)date;
- (instancetype)initWithSnapshot:(FIRDataSnapshot*)snapshot;
- (instancetype)initWithNoteObject:(NoteObject*)noteObject;

- (NSDictionary*)fireModel;

@end
