//
//  CreateAlbumSheetController.m
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 3/2/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "CreateAlbumSheetController.h"

@implementation CreateAlbumSheetController

@synthesize album;
@synthesize isSaving;
@synthesize delegate;

- (void)dealloc
{
	[album release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[self willChangeValueForKey:@"album"];
	album = [[NSMutableDictionary alloc] initWithCapacity:2];
	[self didChangeValueForKey:@"album"];
}

- (void)save:(id)sender
{
	TRACE(@"");
	if([self.delegate respondsToSelector:@selector(createAlbumController:requestedAlbumCreation:)]) {
		self.isSaving = [self.delegate createAlbumController:self requestedAlbumCreation:[NSDictionary dictionaryWithDictionary:album]];
	}
}

- (IBAction)cancel:(id)senderact
{
	TRACE(@"");
	[NSApp endSheet:self.window];
}

@end
