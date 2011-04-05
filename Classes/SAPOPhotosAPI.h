// Photos.h 

#import <Foundation/Foundation.h>
#import "WebService.h"

#import "NSString+Helpers.h"
#import "NSDate+xml.h"

#import "NSDataAdditions.h"

// NOTE: defining all complex type as class so that the order does not matter



#pragma mark Complex Type Interface Definitions 

@class AlbumGetListByUserResult;

#pragma mark -
#pragma mark Main WebService Interface
@interface SAPOPhotosAPI : WebService
{

}

// use only one of the following auth methods
// the last onde that was defined will be used
- (void)setUsername:(NSString *)username password:(NSString *)password;

- (BOOL)isValidAuthorizer;

- (NSDictionary *) albumCreateWithAlbum:(NSDictionary *)album;
- (AlbumGetListByUserResult *) albumGetListByUserWithUser:(NSDictionary *)user page:(NSInteger)page orderBy:(NSString *)orderBy interface:(NSString *)interface;

- (NSDictionary *) imageAddToAlbumWithImage:(NSDictionary *)image interface:(NSString *)interface;
- (NSDictionary *) imageCreateWithImage:(NSDictionary *)image interface:(NSString *)interface;
- (NSDictionary *) imageDetailsWithImage:(NSDictionary *)image;
- (NSDictionary *) imageEditWithImage:(NSDictionary *)image;

@end