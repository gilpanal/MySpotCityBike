//
//  Celda.h
//  Maps
//
//  Created by Jose Manuel Gil on 04/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Celda : NSManagedObject

@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSString * descripcion;
@property (nonatomic) float latitud;
@property (nonatomic) float longitud;

@end
