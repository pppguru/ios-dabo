//
//  GTAccountViewController.h
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import <UIKit/UIKit.h>
#import <FDTakeController.h>
#import "GTBaseViewController.h"

@interface GTProfileViewController : GTBaseViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@property(nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property(nonatomic, weak) IBOutlet UILabel *lblName;
@property(nonatomic, weak) IBOutlet UILabel *lblLikeKeywords;
@property(nonatomic, weak) IBOutlet UILabel *lblLocation;

@property(nonatomic, weak) IBOutlet UIButton *btnWishListTab;
@property(nonatomic, weak) IBOutlet UIButton *btnActivityTab;

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;


@end
