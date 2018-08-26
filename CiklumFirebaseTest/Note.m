//
//  Note.m
//  CiklumFirebaseTest
//
//  Created by Artem Shvets on 25.08.2018.
//  Copyright © 2018 Artem Shvets. All rights reserved.
//

#import "Note.h"
#import "NSDateFormatter+ASDateFormatter.h"

#define TEXT_KEY @"text"
#define CREATE_DATE_KEY @"creationDate"

@implementation Note

- (instancetype)initWithText:(NSString *)text creatDate:(NSDate *)date{
    self = [super init];
    if(self){
        _text = text;
        _createDate = date;
    }
    return self;
}

- (instancetype)initWithSnapshot:(FIRDataSnapshot *)snapshot{
    
    if(!snapshot)
        return nil;
    
    self = [super init];
    if (self) {
        if([snapshot.value isKindOfClass:[NSArray class]] || [snapshot.value isKindOfClass:[NSDictionary class]]){
            _noteID = snapshot.key;
            if ([[snapshot.value valueForKey:TEXT_KEY] isKindOfClass:[NSString class]]) {
                _text = [snapshot.value valueForKey:TEXT_KEY];
            }
            if ([[snapshot.value valueForKey:CREATE_DATE_KEY] isKindOfClass:[NSNumber class]]) {
                NSTimeInterval timestamp = [[snapshot.value valueForKey:CREATE_DATE_KEY] integerValue];
                _createDate = [NSDate dateWithTimeIntervalSinceReferenceDate:timestamp];
            }
        }
    }
    
    return self;
}

- (instancetype)initWithNoteObject:(NoteObject *)noteObject{
    if(!noteObject)
        return nil;
    
    self = [super init];
    if(self){
        _noteID = [noteObject noteID];
        _text = [noteObject text];
        _createDate = [noteObject createDate];
        _saved = YES;
    }
    
    return self;
}

- (NSDictionary *)fireModel{
    NSInteger timeStamp = [self.createDate timeIntervalSinceReferenceDate];
    return @{TEXT_KEY:self.text,
             CREATE_DATE_KEY:@(timeStamp)};
}


@end
