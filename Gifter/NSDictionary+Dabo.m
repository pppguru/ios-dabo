//
//  NSDictionary+Dabo.m
//  Gifter
//
//  Created by Vivudh Pandey on 12/14/15.
//
//

#import "NSDictionary+Dabo.h"

@implementation NSDictionary (Dabo)

+ (id)objectOrNil:(id)object{
    
    if (object && ![object isKindOfClass:[NSNull class]]) {
        
        return object;
    }
    else
        return @"";
}

@end
