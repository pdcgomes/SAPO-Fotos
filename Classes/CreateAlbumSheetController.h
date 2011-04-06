//
//  CreateAlbumSheetController.h
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 3/2/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CreateAlbumSheetController : NSWindowController 
{
	NSMutableDictionary	*album;
	BOOL				isSaving;
	
	NSObject			*delegate;
}

@property (nonatomic, readonly) NSMutableDictionary *album;
@property (nonatomic, assign) BOOL isSaving;
@property (nonatomic, assign) NSObject *delegate;

- (IBAction)cancel:(id)sender;

@end

@interface NSObject(CreateAlbumSheetControllerDelegate)

- (BOOL)createAlbumController:(CreateAlbumSheetController *)controller requestedAlbumCreation:(NSDictionary *)album;

@end