//
//  NSString+StringSizeWithFont.m
//  Gifter
//
//  Created by Muzammil Mohammad on 04/06/15.
//
//

#import "NSString+StringSizeWithFont.h"

@implementation NSString (StringSizeWithFont)

- (CGSize)sizeWithMyFont:(UIFont *)fontToUse
{
    if ([self respondsToSelector:@selector(sizeWithAttributes:)])
    {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self
                                                                             attributes:@
                                              {
                                              NSFontAttributeName: fontToUse
                                              }];
        
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){300, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize size = rect.size;
        
        return size;
    }
    
    float os_version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (os_version <= 8.000000)
    {
        ([self sizeWithFont:fontToUse]);
    }
    
    return CGSizeMake(320, 100);//([self sizeWithFont:fontToUse]);
}


@end
