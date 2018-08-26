//
//  NSDateFormatter+ASDateFormatter.m
//  Foovie
//
//  Created by Artem Shvets on 10.03.16.
//

#import "NSDateFormatter+ASDateFormatter.h"

@implementation NSDateFormatter (ASDateFormatter)

+ (NSString*)stringFromDate:(NSDate*)date withFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    [dateFormatter setDateFormat:format];
    
    NSString* dateString = [dateFormatter stringFromDate:date];
    return dateString;
}
+ (NSDate*)dateFromString:(NSString*)string withFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setLocale:[NSLocale systemLocale]];
	[dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
	
    [dateFormatter setDateFormat:format];
    
    NSDate* date = [dateFormatter dateFromString:string];
    return date;
}
+ (NSString*)stringFromeTimeStamp:(NSInteger)timeStamp withFormat:(NSString*)format
{
    NSDate* start = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    return [self stringFromDate:start withFormat:format];
}
+ (NSString*)dateStringFromFormat:(NSString*)startFormat
                     toDateFormat:(NSString*)finishFormat
                       fromString:(NSString*)dateString
{
    NSDateFormatter *dateFormatter1 = [NSDateFormatter new];
    
    [dateFormatter1 setLocale:[NSLocale currentLocale]];
    [dateFormatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter1 setDateFormat:startFormat];
    NSDate *date = [dateFormatter1 dateFromString:dateString];
    
    NSDateFormatter *dateFormatter2 = [NSDateFormatter new];
    [dateFormatter2 setTimeZone:[NSTimeZone systemTimeZone]];
    
    [dateFormatter2 setDateFormat:finishFormat];    NSString* newDate = [dateFormatter2 stringFromDate:date];
    
    return newDate;
}
+ (NSString *)countDateFromString:(NSString *)dateString {
    
    NSCalendar *gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    [dateFormatter setDateFormat:SERVER_DATE_FORMAT];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSString* stringDate = [NSDateFormatter dateStringFromFormat:SERVER_DATE_FORMAT
                                                    toDateFormat:@"LLLL HH:mm"
                                                      fromString:dateString];
    
    NSDateComponents *endDateComp = [gregorianCalendar components:NSCalendarUnitDay fromDate: date];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterOrdinalStyle;
    NSString* ordinalDay = [formatter stringFromNumber:@(endDateComp.day)];
    NSString* stringToReturn = @"";
    
    if (stringDate && ordinalDay) {
        stringToReturn = [NSString stringWithFormat:@"%@ %@", ordinalDay, stringDate];
    }
    return stringToReturn;
}

@end
