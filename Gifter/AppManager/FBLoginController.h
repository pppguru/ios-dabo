//
//  FBLoginController.h
//  DABO
//
//  Created by Muzammil Mohammad on 29/10/15.
//  Copyright (c) 2015 DABO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FacebookLoginBlock)(NSArray *userInfo);

@interface FBLoginController : NSObject

+ (id)fbAccountsManager;

- (void)FacebookLogin:(FacebookLoginBlock)block;

@end
