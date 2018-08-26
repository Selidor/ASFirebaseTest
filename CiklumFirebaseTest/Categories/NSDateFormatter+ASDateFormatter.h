//
//  NSDateFormatter+ASDateFormatter.h
//  Foovie
//
//  Created by Artem Shvets on 10.03.16.
//

#import <Foundation/Foundation.h>

#define SERVER_DATE_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

@interface NSDateFormatter (ASDateFormatter)

+ (NSString*)stringFromDate:(NSDate*)date withFormat:(NSString*)format;
+ (NSDate*)dateFromString:(NSString*)string withFormat:(NSString*)format;
+ (NSString*)stringFromeTimeStamp:(NSInteger)timeStamp withFormat:(NSString*)format;
+ (NSString*)dateStringFromFormat:(NSString*)startFormat
                     toDateFormat:(NSString*)finishFormat
                       fromString:(NSString*)dateString;
+ (NSString *)countDateFromString:(NSString *)dateString;

@end
