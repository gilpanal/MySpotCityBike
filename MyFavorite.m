//
//  MyFavorite.m
//  Maps
//
//  Created by Jose Manuel Gil on 04/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import "MyFavorite.h"

@implementation MyFavorite

NSManagedObjectModel *managedObjectModel;
NSPersistentStoreCoordinator  *persistentStoreCoordinator;
NSManagedObjectContext *managedObjectContext;

-(void)insertarNuevo:(Celda *)nuevaCelda{
    
    
    NSError *error;
    NSURL *modelURL = [[NSBundle mainBundle]URLForResource:@"Favorito"
                                             withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    NSURL *storeURL = [[self applicationDocumentsDirectory]
                       URLByAppendingPathComponent:@"FavoritesDataBase.sqlite"];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:managedObjectModel];
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                             configuration:nil URL:storeURL options:nil error:&error];
    managedObjectContext = [[NSManagedObjectContext alloc]init];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    NSLog(@"NUEVA CELDA %@", nuevaCelda);
    
    nuevaCelda = (Celda *) [NSEntityDescription insertNewObjectForEntityForName:@"Celda" inManagedObjectContext:managedObjectContext];
    
      NSLog(@"NUEVA CELDA %@", nuevaCelda);
   
    if (![managedObjectContext save:&error]){
        NSLog(@"Error en la inserción: %@, %@", error, [error userInfo]);
    }
  
    [_delegate insertNewLocation:nuevaCelda];
}
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
