// Photos.h 

#import <Foundation/Foundation.h>
#import "WebService.h"

#import "NSString+Helpers.h"
#import "NSDate+xml.h"

#import "NSDataAdditions.h"

// NOTE: defining all complex type as class so that the order does not matter



#pragma mark Complex Type Interface Definitions 

#pragma mark -
#pragma mark Main WebService Interface
@interface SAPOPhotosAPI : WebService
{
}

- (NSDictionary *) albumCreateWithAlbum:(NSDictionary *)album;
- (NSDictionary *) albumGetListByUserWithUser:(NSDictionary *)user page:(NSInteger)page orderBy:(NSString *)orderBy interface:(NSString *)interface;

- (NSDictionary *) imageAddToAlbumWithImage:(NSDictionary *)image interface:(NSString *)interface;
- (NSDictionary *) imageCreateWithImage:(NSDictionary *)image interface:(NSString *)interface;
- (NSDictionary *) imageDetailsWithImage:(NSDictionary *)image;
- (NSDictionary *) imageEditWithImage:(NSDictionary *)image;

- (NSDictionary *) imageGetByColorLikenessWithColor:(NSDictionary *)color interface:(NSString *)interface;
- (NSDictionary *) imageGetListBySearchWithPage:(NSInteger)page interface:(NSString *)interface terms:(NSArray *)terms dateFrom:(NSString *)dateFrom dateTo:(NSString *)dateTo;
- (NSDictionary *) imageGetListByTagsWithTags:(NSArray *)tags page:(NSInteger)page orderBy:(NSString *)orderBy m18:(BOOL)m18 user:(NSDictionary *)user interface:(NSString *)interface;
- (NSDictionary *) imageGetListByUserWithPage:(NSInteger)page user:(NSDictionary *)user;
- (NSDictionary *) imageGetListByUserAlbumWithUser:(NSDictionary *)user album:(NSDictionary *)album page:(NSInteger)page interface:(NSString *)interface orderBy:(NSString *)orderBy;

- (NSDictionary *) userCreateWithUser:(NSDictionary *)user;
- (NSDictionary *) userDetailsWithUser:(NSDictionary *)user interface:(NSDictionary *)interface;
- (NSDictionary *) userGetTagsWithUser:(NSDictionary *)user interface:(NSString *)interface;

- (NSString *) dummyEchoWithEchoStr:(NSString *)echoStr;

@end