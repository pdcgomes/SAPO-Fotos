//
//  AlbumCollection.h
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/21/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XMLelement;

@interface AlbumGetListByUserResult : NSObject 
{
	NSMutableArray		*albums_;
	NSMutableDictionary *result_;
}

@property (nonatomic, readonly) NSArray *albums;
@property (nonatomic, readonly) NSDictionary *result;

- (id)initWithAlbums:(NSArray *)albums result:(XMLelement *)result;
- (void)addAlbums:(NSArray *)albums;

@end

@interface NSDictionary(PhotoAlbumAdditions)

- (NSString *)albumID;
- (NSString *)albumName;

@end
