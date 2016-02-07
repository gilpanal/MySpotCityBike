//
//  FavoritesTableViewController.h
//  Maps
//
//  Created by Jose Manuel Gil on 04/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Celda.h"



@protocol FavoritesTableViewControllerDelegate;

@interface FavoritesTableViewController : UITableViewController 


@property (nonatomic, weak) id<FavoritesTableViewControllerDelegate> delegate;

- (void)addToFavorites:(NSString *)nombreFavorito descripcionFavorito:(NSString*)descripcion latitudFavorito:(float)latitud longitudFavorito:(float)longitud;

- (NSArray*) recuperarListaFavoritos;

@end



@protocol FavoritesTableViewControllerDelegate <NSObject>

- (void)addItemViewController:(FavoritesTableViewController *)controller withNewEventName:(NSString *)eventName;


@end