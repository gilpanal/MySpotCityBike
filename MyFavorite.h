//
//  MyFavorite.h
//  Maps
//
//  Created by Jose Manuel Gil on 04/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Celda.h"
@protocol FavoriteDelegate;

@interface MyFavorite : NSObject

@property (weak, nonatomic) id<FavoriteDelegate> delegate;
-(void) insertarNuevo:(Celda*)nuevaCelda;;
@end

@protocol FavoriteDelegate <NSObject>

-(void)insertNewLocation:(Celda*)nuevaCelda;

@end