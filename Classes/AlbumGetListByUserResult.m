//
//  AlbumCollection.m
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/21/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "AlbumGetListByUserResult.h"
#import "XMLelement.h"

// Some properties may conflict with internal reserved keywords (such as "description")
// This sanitizes the input keys
#define ALBUM_PROPERTY_KEY_PREFIX @"__albumProperty_"

@interface AlbumGetListByUserResult(Private)

- (void)addAlbumWithXMLElement:(XMLelement *)element;

@end

@implementation AlbumGetListByUserResult

@dynamic albums;
@dynamic result;

- (void)dealloc
{
	SKSafeRelease(albums_);
	SKSafeRelease(result_);
	
	[super dealloc];
}

- (id)initWithAlbums:(NSArray *)listOfAlbums result:(XMLelement *)totals
{
	if((self = [super init])) {
		albums_ = [[NSMutableArray alloc] initWithCapacity:[listOfAlbums count]];
		for(XMLelement *element in listOfAlbums) {
			[self addAlbumWithXMLElement:element];
		}
		result_ = [[NSMutableDictionary alloc] initWithCapacity:[totals.children count]];
		for(XMLelement *child in totals.children) {
			[result_ setObject:child.text forKey:SKStringWithFormat(@"%@%@", ALBUM_PROPERTY_KEY_PREFIX, child.name)];
		}
	}
	
	return self;
}

- (void)addAlbums:(NSArray *)listOfAlbums
{
	for(XMLelement *element in listOfAlbums) {
		[self addAlbumWithXMLElement:element];
	}
}


#pragma mark -
#pragma mark Properties

- (NSArray *)albums
{
	return [NSArray arrayWithArray:albums_];
}

- (NSDictionary *)result
{
	return [NSDictionary dictionaryWithDictionary:result_];
}

#pragma mark -
#pragma mark Private Methods

- (void)addAlbumWithXMLElement:(XMLelement *)element
{
	NSMutableDictionary *album = [[NSMutableDictionary alloc] initWithCapacity:[element.children count]];
	for(XMLelement *child in element.children) {
//		[album setObject:child.text forKey:SKStringWithFormat(@"%@%@", ALBUM_PROPERTY_KEY_PREFIX, child.name)];
		[album setObject:child.text forKey:child.name];
	}
	[albums_ addObject:album];
	[album release];
}

@end

@implementation NSDictionary(PhotoAlbumAdditions)

- (NSString *)albumID
{
	return [self objectForKey:@"id"];
//	return [self objectForKey:SKStringWithFormat(@"%@%@", ALBUM_PROPERTY_KEY_PREFIX, @"id")];
}

- (NSString *)albumName
{
	return [self objectForKey:@"title"];
//	return [self objectForKey:SKStringWithFormat(@"%@%@", ALBUM_PROPERTY_KEY_PREFIX, @"title")];
}

@end

