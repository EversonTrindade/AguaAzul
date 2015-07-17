//
//  DataBase.m
//  Agua Azul
//
//  Created by Everson Trindade on 12/22/14.
//  Copyright (c) 2014 TADS. All rights reserved.
//

#import "DataBase.h"

@implementation DataBase

@synthesize databasePath;
@synthesize myDatabase;
@synthesize statusOfAddingToDB;

//Setar as informacoes vindas do json como parametros
- (void)createDataBase
{

    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"AguaAzulDB.db"]];
    NSLog(@"DB Path: %@", databasePath);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        if (sqlite3_open(dbpath, &myDatabase) == SQLITE_OK) {
            char *errMsg;
            
            NSString *createSQL = [NSString stringWithFormat: @"CREATE TABLE PRAIATABLE (ID INTEGER PRIMARY KEY AUTOINCREMENT, CODIGOPRAIA TEXT, NOME TEXT, LATITUDE TEXT, LONGITUDE TEXT, BALNEABILIDADE TEXT)"];
            
            const char *create_stmt = [createSQL UTF8String];
            
            if (sqlite3_exec(myDatabase, create_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                statusOfAddingToDB = @"Failed to create table";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB Status" message:statusOfAddingToDB delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                statusOfAddingToDB = @"Success in creating table";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB Status" message:statusOfAddingToDB delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            sqlite3_close(myDatabase);
        } else {
            statusOfAddingToDB = @"Failed to open/create database";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB Status" message:statusOfAddingToDB delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }else if ([filemgr fileExistsAtPath: databasePath ] == YES){
        if (sqlite3_open(dbpath, &myDatabase) == SQLITE_OK) {
            char *err;
            NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM PRAIATABLE"];
            const char *delete_stmt = [deleteSQL UTF8String];
            
            if (sqlite3_exec(myDatabase, delete_stmt, NULL, NULL, &err) == SQLITE_OK) {
                NSLog(@"DATABASE DELETED ;)");
                //[self createDataBase];
            }else{
                NSLog(@"DELETE DATABASE ERROR: %s", err);
            }
        }
    }
}

- (void) saveData:(NSString*)nome addLat:(NSString*)latitude addLong:(NSString*)longitude addBaln:(NSString*)balneabilidadea addCodPraia:(NSString*)codPraia{
    
    //sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &myDatabase) == SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO PRAIATABLE (CODIGOPRAIA, NOME, LATITUDE, LONGITUDE, BALNEABILIDADE) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", codPraia, nome, latitude, longitude, balneabilidadea];
        
        const char *insert_stmt = [insertSQL UTF8String];
        //sqlite3_prepare_v2(myDatabase, insert_stmt, -1, &statement, NULL);
        
        
        /*
        if (sqlite3_prepare_v2(myDatabase, insert_stmt, -1, &statement, NULL) == SQLITE_OK) {
            //statusOfAddingToDB = [NSString stringWithFormat:@"Text added -- %@", test];
            NSLog(@"DATA SAVED");
        } else {
            //statusOfAddingToDB = @"Failed to add contact";
            NSLog(@"SAVE DATA ERRROR");
        }
        */
        
        
        char *err;
        int code = sqlite3_exec(myDatabase, insert_stmt, NULL, NULL, &err);
        if (code != SQLITE_OK) {
            NSLog(@"SOMETHING IS WRONG: %s", err);
        }else{
            NSLog(@"Data Saved");
        }
        
        
        
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB Status" message:statusOfAddingToDB delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        */
        //sqlite3_finalize(statement);
        //sqlite3_close(myDatabase);
    }else{
        NSLog(@"ERROR");
    }
}

-(void) deleteData{
    
    const char *dbpath = [databasePath UTF8String];
    @try {
        if (sqlite3_open(dbpath, &myDatabase) == SQLITE_OK) {
            NSString *deleteSQL = [NSString stringWithFormat:@"DELETE * FROM PRAIATABLE"];
            char *err;
            const char *delete_stmt = [deleteSQL UTF8String];
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(myDatabase, delete_stmt, -1, &statement, NULL) == SQLITE_OK){
                NSLog(@"DATABASE DELETED");
                //[self createDataBase];
            }else{
                NSLog(@"DELETE DATABASE ERROR: %s", err);
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERRO FOI AQUI POW");
    }
}


-(NSMutableArray*) findData{
    NSMutableArray *praias = [[NSMutableArray alloc] init];
    NSMutableDictionary *dataStored = [[NSMutableDictionary alloc] init];
    
    NSString *codigo;
    NSString *nome;
    NSString *lat;
    NSString *lon;
    NSString *baln;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &myDatabase) == SQLITE_OK) {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT CODIGOPRAIA, NOME, LATITUDE, LONGITUDE, BALNEABILIDADE FROM PRAIATABLE"];
        const char *select_stmt = [selectSQL UTF8String];
        if (sqlite3_prepare_v2(myDatabase, select_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                codigo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                nome = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                lat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                lon = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                baln = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                
                //NSLog(@"TESTES: %@, %@, %@, %@, %@", codigo, nome, lat, lon, baln);
                
                [dataStored setObject:codigo forKey:@"codigo"];
                [dataStored setObject:nome forKey:@"nome"];
                [dataStored setObject:lat forKey:@"lat"];
                [dataStored setObject:lon forKey:@"lon"];
                [dataStored setObject:baln forKey:@"baln"];
                
                [praias addObject:[dataStored copy]];
            }
        }else{
            
            NSLog(@"SELECT ERROR");
        }
    }
    
    return praias;
}

-(NSMutableArray*) findLatLong:(NSString*)nomePraia{
    NSMutableArray *praias = [[NSMutableArray alloc] init];
    NSMutableDictionary *dataStored = [[NSMutableDictionary alloc] init];
    
    NSString *codigo;
    NSString *nome;
    NSString *lat;
    NSString *lon;
    NSString *baln;
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &myDatabase) == SQLITE_OK) {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT CODIGOPRAIA, NOME, LATITUDE, LONGITUDE, BALNEABILIDADE FROM PRAIATABLE"];
        const char *select_stmt = [selectSQL UTF8String];
        if (sqlite3_prepare_v2(myDatabase, select_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                codigo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                nome = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                lat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                lon = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                baln = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                
                NSLog(@"TESTES: %@, %@, %@, %@, %@", codigo, nome, lat, lon, baln);

                
                [dataStored setObject:codigo forKey:@"codigo"];
                [dataStored setObject:nome forKey:@"nome"];
                [dataStored setObject:lat forKey:@"lat"];
                [dataStored setObject:lon forKey:@"lon"];
                [dataStored setObject:baln forKey:@"baln"];
                
                [praias addObject:[dataStored copy]];
            }
        }else{
            
            NSLog(@"SELECT ERROR");
        }
    }
    
    return praias;
}


@end
