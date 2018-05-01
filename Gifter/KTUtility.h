//
//  KTUtility.h
//  Created by Karthik on 05/07/2014.

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import <UIKit/UIKit.h>

@interface KTUtility : NSObject

/**
 *  Creates an image based on the color.
 *
 *  @param color Color that the area needs to fill.
 *  @return image of that color.
 */
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (void)setTextFieldBordersWhite:(UITextField *)f withLeftImage:(UIImage *)imgLeft;
+ (void)setTextFieldBordersRed:(UITextField *)f withLeftImage:(UIImage *)imgLeft;
/**
 *  Validates email address
 *
 *  @param candidate Candidate string
 *
 *  @return valid email or not.
 */
+ (BOOL)validateEmail:(NSString *)candidate;

/**
 *  Set's the font for the application.
 *  @param masterView the view for which all controls have to be altered.
 */

+ (void)setFontStyle:(UIView *)masterView;

/**
 *  Returns a valid value for the key
 *
 *  @param aKey key
 *  @param dict the key-value pair
 *
 *  @return value or nil
 */
+ (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

/**
 *  Create and add a new event to the calendar after taking the correct
 *permission.
 *
 *  @param eventTitle Title of the event
 *  @param startHour  starting hour of the event
 *  @param endingHour ending time of the event
 *  @param callback   callback to report the status.
 */
+ (void)addEventToCalendarWithTitle:(NSString *)eventTitle
                       startingFrom:(NSInteger)startHour
                           endingAt:(NSInteger)endingHour
                       withCallback:
                           (void (^)(BOOL success,
                                     BOOL isPermissionProvided))callback;

/**
 *  Removes all the key-value pairs stored in user defaults.
 */
+ (void)removeAllUserDefaultValues;

+ (void)setButtonUI:(UIButton *)button;
+ (void)setAlternativeButtonUI:(UIButton *)button;
+ (void)setRoundedButtonUI:(UIButton *)button;
+ (void)setTextFieldBorders:(UITextField *)f withLeftImage:(UIImage *)imgLeft;
+ (void)setTextFieldBorders:(UITextField *)f withLeftImage:(UIImage *)imgLeft withLeftImageColor:(UIColor*)color;
+ (void)setTextFieldLessBorders:(UITextField *)f withLeftImage:(UIImage *)imgLeft;
+ (void)setTextFieldWithoutBorders:(UITextField *)f withLeftImage:(UIImage *)imgLeft;
+ (void)setViewWithBottomBorder:(UIView *)f;

@end