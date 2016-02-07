//
//  CollectionWonderViewController.h
//  Maps
//
//  Created by Jose Manuel Gil on 17/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionCell.h"
#import "SupplementaryView.h"
#import "Celda.h"

@interface CollectionWonderViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSMutableArray *sevenWonderImages;
@property (strong, nonatomic) NSMutableArray *descriptions;
@property (strong, nonatomic) NSMutableArray *coordenadas;

@end
