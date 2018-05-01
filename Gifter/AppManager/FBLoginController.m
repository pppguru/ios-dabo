//
//  FBLoginController.m
//  DABO
//
//  Created by Muzammil Mohammad on 29/10/15.
//  Copyright (c) 2015 DABO. All rights reserved.
//

#import "FBLoginController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FBLoginController ()
{
    FacebookLoginBlock    _facebookLoginBlock;
}

@end

@implementation FBLoginController

+ (id)fbAccountsManager
{
    static dispatch_once_t onceQueue;
    static FBLoginController *accountsManager = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      if (!accountsManager) {
                          
                          accountsManager = [[self alloc]
                                             init];
                      }
                  });
    
    return accountsManager;
}

+ (UIViewController*)getCurrentViewController
{
    UINavigationController *navController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    if (navController) {
        
        UIViewController *topController = [navController visibleViewController];
        
        return topController;
    }

    return nil;
}

- (void)FacebookLogin:(FacebookLoginBlock)block;
{    
    [FBSDKSettings setAppID:@"904115216349460"];
     
    _facebookLoginBlock = [block copy];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    login.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    
    [login logOut];
    
    [login logInWithReadPermissions:@[@"email", @"public_profile"] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        if (error)
        {
            _facebookLoginBlock(nil);
        }
        else if (result.isCancelled)
        {
            _facebookLoginBlock(nil);
        }
        else
        {
            FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
            
            if (token) {
                
                NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                [parameters setValue:@"id, name, picture, first_name, last_name, email" forKey:@"fields"];
                
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection * connection, id result, NSError* error) {
                     
                     if (error)
                         _facebookLoginBlock(nil);
                     
                     else
                         _facebookLoginBlock(result);
                     
                 }];
            }
            
            else
                _facebookLoginBlock(nil);
        }
    }];
}

@end
