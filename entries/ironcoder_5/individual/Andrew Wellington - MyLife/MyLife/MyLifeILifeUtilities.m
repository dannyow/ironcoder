/*
 * Project:     MyLife
 * File:        MyLifeILifeUtilities.m
 * Author:      Andrew Wellington
 *
 * License:
 * Copyright (C) 2007 Andrew Wellington.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MyLifeILifeUtilities.h"


@implementation MyLifeILifeUtilities
+ (NSArray *)iPhotoAlbums
{
    NSString *albumDataPath = [@"~/Pictures/iPhoto Library/AlbumData.xml" stringByExpandingTildeInPath];
    NSMutableArray *albums = [NSMutableArray array];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:albumDataPath]) {
        NSData *plistData;
        NSString *error;
        NSPropertyListFormat format;
        NSDictionary *plist;
        
        //suck in all the data from the iPhoto Library's album plist
        plistData = [NSData dataWithContentsOfFile:albumDataPath];
        plist = [NSPropertyListSerialization propertyListFromData:plistData
                                                  mutabilityOption:NSPropertyListImmutable
                                                            format:&format
                                                  errorDescription:&error];
        
        if ([plist objectForKey:@"List of Albums"]) {
            NSEnumerator *albumEnum = [[plist objectForKey:@"List of Albums"] objectEnumerator];
            id album;
            
            while ((album = [albumEnum nextObject]))
            {
                if ([album objectForKey:@"AlbumName"])
                    [albums addObject:[album objectForKey:@"AlbumName"]];
            }
        } else {
            return nil;
        }
        return albums;
    }
    return nil;
}

+ (NSArray *)iPhotoPathsForAlbum:(NSString *)albumName
{
    NSString *albumDataPath = [@"~/Pictures/iPhoto Library/AlbumData.xml" stringByExpandingTildeInPath];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:albumDataPath]) {
        NSData *plistData;
        NSString *error;
        NSPropertyListFormat format;
        NSDictionary *plist;
        
        //suck in all the data from the iPhoto Library's album plist
        plistData = [NSData dataWithContentsOfFile:albumDataPath];
        plist = [NSPropertyListSerialization propertyListFromData:plistData
                                                  mutabilityOption:NSPropertyListImmutable
                                                            format:&format
                                                  errorDescription:&error];
        
        if ([plist objectForKey:@"List of Albums"]) {
            NSEnumerator *albumEnum = [[plist objectForKey:@"List of Albums"] objectEnumerator];
            id album;
            
            while ((album = [albumEnum nextObject]))
            {
                if ([album objectForKey:@"AlbumName"] &&
                    [[album objectForKey:@"AlbumName"] isEqualToString:albumName])
                {
                    NSDictionary *imageList = [plist objectForKey:@"Master Image List"];
                    NSEnumerator *itemEnum = [[album objectForKey:@"KeyList"] objectEnumerator];
                    NSString *itemKey;
                    NSMutableArray *paths;
                    
                    if (!imageList)
                        return nil;
                    
                    paths = [NSMutableArray array];
                    while ((itemKey = [itemEnum nextObject]))
                    {
                        if ([imageList objectForKey:itemKey] && 
                            [[imageList objectForKey:itemKey] objectForKey:@"ImagePath"])
                            [paths addObject:[[imageList objectForKey:itemKey] objectForKey:@"ImagePath"]];
                    }
                    
                    if ([paths count])
                        return paths;
                    else
                        return nil;
                }
            }
        } else {
            return nil;
        }
    }
    return nil;
    
}
@end
