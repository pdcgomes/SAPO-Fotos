//
//  iPhotoExportPlugin.m
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/22/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "iPhotoExportPlugin.h"

@implementation iPhotoExportPlugin

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[super dealloc];
}

- (id)initWithExportImageObj:(id)fp8 
{
   	if((self = [super initWithNibName:@"iPhotoExportView"])) {
		_exportManager = fp8;
//		[NSBundle loadNibNamed:@"iPhotoExportView" owner:self];
	}
	return self;
} 


#pragma mark -
#pragma mark AbstractExportPlugin Overrides

- (id)defaultDirectory 
{
    return [NSString stringWithFormat:@"%@/Pictures/iPhoto Exports", NSHomeDirectory()];
}

- (id)getDestinationPath 
{
	return [NSString stringWithFormat: @"%@/ExampleOutput.txt", NSHomeDirectory()];
}

- (BOOL)wantsDestinationPrompt 
{
    return NO;
}

#pragma mark -
#pragma mark iPhoto ExportMgr

- (void)performExport:(id)fp8 
{
	TRACE(@"ExampleExport -- performExport");
}

- (void)startExport:(id)fp8 
{
    TRACE(@"ExampleExport -- startExport");
	
	// open the file passed in as a parameter
    FILE *stream = fopen([fp8 UTF8String], "w");
	
    fprintf(stream, "iPhoto Example Export\n");
	fprintf(stream, "=====================\n");
    fprintf(stream, "Album Name: %s\n", [[_exportManager albumNameAtIndex:0] UTF8String]);
	fprintf(stream, "Album Comments: %s\n", [[_exportManager albumCommentsAtIndex:0] UTF8String]);
	
	int i;
	for(i = 0; i < [_exportManager imageCount]; i++) {
		fprintf(stream, "\nImage %d\n", (i+1));
		fprintf(stream, "-------------\n");
		fprintf(stream, "Path: %s\n", [[_exportManager imagePathAtIndex:i] UTF8String]);
		fprintf(stream, "Caption: %s\n", [[_exportManager imageTitleAtIndex:i] UTF8String]);
        fprintf(stream, "Date: %s\n", [[[_exportManager imageDateAtIndex:i] description] UTF8String]);
		
		NSArray *keywords = [_exportManager imageKeywordsAtIndex:i];
		int j;
		for(j = 0; j < [keywords count]; j++) {
			fprintf(stream, "Keyword: %s\n", [[keywords objectAtIndex:j] UTF8String]);
		}
		fprintf(stream, "Comments: %s\n", [[_exportManager imageCommentsAtIndex:i] UTF8String]);
	}
	
    fclose(stream);
}

- (BOOL)validateUserCreatedPath:(id)fp8 
{
    return YES;
}

- (BOOL)treatSingleSelectionDifferently 
{
    return NO;
}

- (void)viewWillBeDeactivated 
{
	[super willBeDeactivated];
}

- (void)viewWillBeActivated 
{
	[super willBeActivated];
}

- (void)clickExport 
{	
	TRACE(@"ExampleExport -- clickExport");
}

- (BOOL)handlesMovieFiles
{
	return NO;
}

- (id)defaultFileName 
{
	// @@ change this
	return @"ExampleOutput.txt";
}

- (id)requiredFileType 
{
	return @"txt";
}

- (id)description 
{
    return NSLocalizedString(@"ExampleExport", @"Name of the Plugin");
}

- (id)name 
{
    return NSLocalizedString(@"ExampleExport", @"Name of the Project");
}

- (void)cancelExport 
{
	TRACE(@"ExampleExport -- cancelExport");
}

- (void)unlockProgress 
{
	TRACE(@"ExampleExport -- unlockProgress");
}

- (void)lockProgress 
{
	TRACE(@"ExampleExport -- lockProgress");
}

- (void *)progress 
{	
	return (void *)@""; 
}

@end
