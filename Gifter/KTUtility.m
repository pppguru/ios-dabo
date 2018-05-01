//
//  KTUtility.m
//  Created by Karthik on 05/07/2014.
#import "KTUtility.h"
#import <EventKit/EventKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@implementation KTUtility

+ (UIImage *)imageWithColor:(UIColor *)color {
  CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, rect);

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

+ (BOOL)validateEmail:(NSString *)candidate {
  NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
  NSPredicate *emailTest =
      [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

  return [emailTest evaluateWithObject:candidate];
}

+ (void)setFontStyle:(UIView *)masterView {
  for (id view in [masterView subviews]) {
    if ([view isKindOfClass:[UITextField class]]) {
      [(UITextField *)view
          setFont:SKIA_LIGHT([[(UITextField *)view font] pointSize])];
    } else if ([view isKindOfClass:[UIButton class]]) {
      [[(UIButton *)view titleLabel]
          setFont:SKIA_LIGHT([[[(UIButton *)view titleLabel] font] pointSize])];
    } else if ([view isKindOfClass:[UILabel class]]) {
      [(UILabel *)view setFont:SKIA_LIGHT([[(UILabel *)view font] pointSize])];
    } else if ([view isKindOfClass:[UIView class]]) {
      [KTUtility setFontStyle:(UIView *)view];
    }
  }
}

+ (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict {
  id object = [dict objectForKey:aKey];
  return [object isEqual:[NSNull null]] ? nil : object;
}

+ (void)addEventToCalendarWithTitle:(NSString *)eventTitle
                       startingFrom:(NSInteger)startHour
                           endingAt:(NSInteger)endingHour
                       withCallback:
                           (void (^)(BOOL success,
                                     BOOL isPermissionProvided))callback {
  EKEventStore *eventStore = [[EKEventStore alloc] init];
  if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:
                                                              completion:)]) {
    [eventStore requestAccessToEntityType:EKEntityTypeEvent
                               completion:^(BOOL granted, NSError *error) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                   if (error) {
                                     callback(NO, YES);
                                   } else if (!granted) {
                                     callback(NO, NO);
                                   } else {
                                     NSError *er =
                                         [KTUtility addEvent:eventTitle
                                                startingFrom:startHour
                                                    endingAt:endingHour
                                              withEventStore:eventStore];

                                     callback(er ? NO : YES, YES);
                                   }
                                 });
                               }];
  } else {
    NSError *er = [KTUtility addEvent:eventTitle
                         startingFrom:startHour
                             endingAt:endingHour
                       withEventStore:eventStore];
    callback(er ? NO : YES, YES);
  }
}

+ (NSError *)addEvent:(NSString *)eventTitle
         startingFrom:(NSInteger)startHour
             endingAt:(NSInteger)endingHour
       withEventStore:(EKEventStore *)eventStore {
  EKEvent *event = [EKEvent eventWithEventStore:eventStore];
  event.title = eventTitle;

  NSDateFormatter *tempFormatter = [[NSDateFormatter alloc] init];
  [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
  [tempFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  event.startDate = [NSDate dateWithTimeIntervalSince1970:startHour];
  event.endDate = [NSDate dateWithTimeIntervalSince1970:endingHour];

  [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 24]];
  [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];

  [event setCalendar:[eventStore defaultCalendarForNewEvents]];
  NSError *err;
  [eventStore saveEvent:event span:EKSpanThisEvent error:&err];

  return err;
}

+ (void)removeAllUserDefaultValues {
  NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
  NSDictionary *dict = [defs dictionaryRepresentation];
  for (id key in dict) {
    [defs removeObjectForKey:key];
  }
  [defs synchronize];
}

+ (void)setButtonUI:(UIButton *)button {
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [[button titleLabel] setFont:SNAPPY_MEDIUM(14)];
  [[button layer] setBorderWidth:0.0f];
  [[button layer] setCornerRadius:4.0f];
  [button setBackgroundColor:GT_RED];
  UIColor *color = [UIColor colorWithRed:1 green:1.0 blue:1.0 alpha:0.5];
  [[button layer] setBorderColor:color.CGColor];
}

+ (void)setAlternativeButtonUI:(UIButton *)button {
  [button setTitleColor:GT_RED forState:UIControlStateNormal];
  [[button titleLabel] setFont:SNAPPY_MEDIUM(14)];
  [[button layer] setBorderWidth:0.0f];
  [[button layer] setCornerRadius:4.0f];
  [button setBackgroundColor:[UIColor whiteColor]];
  UIColor *color = GT_LIGHT_RED;
  [[button layer] setBorderColor:color.CGColor];
}

+ (void)setRoundedButtonUI:(UIButton *)button {
    [[button titleLabel] setFont:SNAPPY_MEDIUM(16)];
    [[button layer] setBorderWidth:0.0f];
    [[button layer] setCornerRadius:button.frame.size.height / 2.0f];
}



+ (void)setTextFieldBordersWhite:(UITextField *)f withLeftImage:(UIImage *)imgLeft {
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       CALayer *bottomBorder = [CALayer layer];
                       bottomBorder.frame =
                       CGRectMake(0.0f, f.frame.size.height - 1, f.frame.size.width, 0.5f);
                       bottomBorder.backgroundColor =
                       [UIColor whiteColor].CGColor;
                       [f.layer addSublayer:bottomBorder];
                       [f setFont:SKIA_REGULAR(f.font.pointSize)];
                       [f setValue:[UIColor colorWithRed:179.0/255.0 green:173.0/255.0 blue:172.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
                   });
    
    if (imgLeft) {
        UIImageView *leftImageView = [[UIImageView alloc] initWithImage:imgLeft];
        
        [leftImageView setFrame:CGRectMake(0, 5, 18, 18)];
        [leftImageView setTintColor:[UIColor whiteColor]];
        [leftImageView setContentMode:UIViewContentModeScaleAspectFit];
        [leftImageView setClipsToBounds:YES];
        
        UIView *v = [[UIView alloc]
                     initWithFrame:CGRectMake(0, 0, 35, f.frame.size.height)];
        [v addSubview:leftImageView];
        [f setLeftView:v];
        [f setLeftViewMode:UITextFieldViewModeAlways];
    }
}


+ (void)setTextFieldBordersRed:(UITextField *)f withLeftImage:(UIImage *)imgLeft {
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       CALayer *bottomBorder = [CALayer layer];
                       bottomBorder.frame =
                       CGRectMake(0.0f, f.frame.size.height - 1, f.frame.size.width, 0.5f);
                       bottomBorder.backgroundColor =
                       GT_RED.CGColor;
                       [f.layer addSublayer:bottomBorder];
                       [f setFont:SKIA_REGULAR(f.font.pointSize)];
                       [f setValue:[UIColor colorWithRed:179.0/255.0 green:173.0/255.0 blue:172.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
                   });
    
    if (imgLeft) {
        UIImageView *leftImageView = [[UIImageView alloc] initWithImage:imgLeft];
        
        [leftImageView setFrame:CGRectMake(0, 5, 18, 18)];
        [leftImageView setTintColor:GT_RED];
        [leftImageView setContentMode:UIViewContentModeScaleAspectFit];
        [leftImageView setClipsToBounds:YES];
        
        UIView *v = [[UIView alloc]
                     initWithFrame:CGRectMake(0, 0, 35, f.frame.size.height)];
        [v addSubview:leftImageView];
        [f setLeftView:v];
        [f setLeftViewMode:UITextFieldViewModeAlways];
    }
}


+ (void)setTextFieldBorders:(UITextField *)f withLeftImage:(UIImage *)imgLeft {
    [KTUtility setTextFieldBorders:f withLeftImage:imgLeft withLeftImageColor:nil];
}

+ (void)setTextFieldBorders:(UITextField *)f withLeftImage:(UIImage *)imgLeft withLeftImageColor:(UIColor*)color{
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       CALayer *bottomBorder = [CALayer layer];
                       bottomBorder.frame =
                       CGRectMake(0.0f, f.frame.size.height - 1, f.frame.size.width, 0.5f);
                       bottomBorder.backgroundColor =
                       [UIColor colorWithRed:.72 green:.72 blue:.72 alpha:0.5].CGColor;
                       [f.layer addSublayer:bottomBorder];
                       [f setFont:SKIA_REGULAR(f.font.pointSize)];
                   });
    
    if (imgLeft) {
        UIImageView *leftImageView = [[UIImageView alloc] initWithImage:imgLeft];
        
        [leftImageView setFrame:CGRectMake(0, 5, 18, 18)];
        
        if (!color) color = GT_LIGHT_RED;
        [leftImageView setTintColor:color];
        [leftImageView setContentMode:UIViewContentModeScaleAspectFit];
        [leftImageView setClipsToBounds:YES];
        
        UIView *v = [[UIView alloc]
                     initWithFrame:CGRectMake(0, 0, 35, f.frame.size.height)];
        [v addSubview:leftImageView];
        [f setLeftView:v];
        [f setLeftViewMode:UITextFieldViewModeAlways];
    }
}



+ (void)setTextFieldLessBorders:(UITextField *)f withLeftImage:(UIImage *)imgLeft {
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       CALayer *bottomBorder = [CALayer layer];
                       bottomBorder.frame =
                       CGRectMake(25.f, f.frame.size.height - 1, f.frame.size.width - 25.f, 0.5f);
                       bottomBorder.backgroundColor =
                       [UIColor colorWithRed:.72 green:.72 blue:.72 alpha:0.5].CGColor;
                       [f.layer addSublayer:bottomBorder];
                       [f setFont:SKIA_REGULAR(f.font.pointSize)];
                   });
    
    if (imgLeft) {
        UIImageView *leftImageView = [[UIImageView alloc] initWithImage:imgLeft];
        
        [leftImageView setFrame:CGRectMake(0, 5, 18, 18)];
        [leftImageView setTintColor:GT_LIGHT_RED];
        [leftImageView setContentMode:UIViewContentModeScaleAspectFit];
        [leftImageView setClipsToBounds:YES];
        
        UIView *v = [[UIView alloc]
                     initWithFrame:CGRectMake(0, 0, 35, f.frame.size.height)];
        [v addSubview:leftImageView];
        [f setLeftView:v];
        [f setLeftViewMode:UITextFieldViewModeAlways];
    }
}

+ (void)setTextFieldWithoutBorders:(UITextField *)f withLeftImage:(UIImage *)imgLeft {
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [f setFont:SKIA_REGULAR(f.font.pointSize)];
                   });
    
    if (imgLeft) {
        UIImageView *leftImageView = [[UIImageView alloc] initWithImage:imgLeft];
        
        [leftImageView setFrame:CGRectMake(0, 5, 18, 18)];
        [leftImageView setTintColor:GT_LIGHT_RED];
        [leftImageView setContentMode:UIViewContentModeScaleAspectFit];
        [leftImageView setClipsToBounds:YES];
        
        UIView *v = [[UIView alloc]
                     initWithFrame:CGRectMake(0, 0, 35, f.frame.size.height)];
        [v addSubview:leftImageView];
        [f setLeftView:v];
        [f setLeftViewMode:UITextFieldViewModeAlways];
    }
}

+ (void)setViewWithBottomBorder:(UIView *)f{
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       CALayer *bottomBorder = [CALayer layer];
                       bottomBorder.frame =
                       CGRectMake(0.0f, f.frame.size.height - 1, f.frame.size.width, 0.5f);
                       bottomBorder.backgroundColor =
                       [UIColor colorWithRed:.72 green:.72 blue:.72 alpha:0.5].CGColor;
                       [f.layer addSublayer:bottomBorder];
                   });
    
}




@end