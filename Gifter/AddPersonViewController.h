//
//  AddPersonViewController.h
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import <UIKit/UIKit.h>
#import "GTBaseViewController.h"
#import "UIPickerView+Blocks.h"
#import "GTGiftViewController.h"

@interface AddPersonViewController : GTBaseViewController

- (void)loadEditMode:(NSDictionary *)details;
- (void)loadSubChild:(NSString *)parentId withType:(NSUInteger)type;

@property(nonatomic, assign) NSUInteger baseSelectedType;

- (IBAction)suggestGift:(id)sender;

@end
