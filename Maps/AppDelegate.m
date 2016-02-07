//
//  AppDelegate.m
//  Maps
//
//  Created by Jose Manuel Gil on 01/05/14.
//  Copyright (c) 2014 Jose Manuel Gil. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Descarga los datos de city bike al arrancar la aplicacion si no existen
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"arrayCityBikes"]) {

        [self  descargarInfoCityBike:@"http://api.citybik.es/networks.json"];        
        
    }
 

    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/////////////////////////////////////////////////////////////////////////////////////////
// PARA DESCARGAR LOS DATOS DE CITY BIKES AL ARRANCAR LA APLICACION

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
  
}
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    // NSLog(@"Received response: %@", response);
    // It can be called multiple times, for example in the case of a redirect, so each time we reset the data.
    [_dataJSON setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_dataJSON appendData:data];
}

// Esta funcion se llama de manera automatica cuando finaliza la conexion y se obtienen los datos
-(void) connectionDidFinishLoading:(NSURLConnection *) connection {
    
    NSError *e = nil;
    NSURL *myURL = [[connection currentRequest] URL];
    NSString *myStringURL = [myURL absoluteString];
    
    // Si la peticion es a api.citybik.es/networks
    if([myStringURL isEqualToString:@"http://api.citybik.es/networks.json"]){
        
        _jsonArray = [NSJSONSerialization JSONObjectWithData:_dataJSON options: NSJSONReadingMutableContainers error: &e];
        if (!_jsonArray) {
            
            NSLog(@"Error parsing JSON: %@", e);
        }
         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:_jsonArray forKey:@"arrayCityBikes"];
        [userDefaults synchronize];
    }
    
}

// Funcion que hace la peticion al web service de CityBike para descargar la informacion
- (void) descargarInfoCityBike: (NSString *)stringUrl{
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    // Petición NSURLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *conexion = [NSURLConnection connectionWithRequest:request delegate:self];
    if (conexion){
        
        _dataJSON = [[NSMutableData alloc] init];
        
    }else{
        NSLog(@"ERROR. Imposible realizar la conexión");
        
    }
    
}


@end
