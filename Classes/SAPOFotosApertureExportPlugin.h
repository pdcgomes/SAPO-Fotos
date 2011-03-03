	
//	
//	SAPOFotosApertureExportPlugin.h
//	SAPOFotosApertureExportPlugin
//
//	Created by Pedro Gomes on 2/15/11.
//	Copyright SAPO 2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "ApertureExportManager.h"
#import "ApertureExportPlugIn.h"
#import "AbstractExportPlugin.h"

@interface SAPOFotosApertureExportPlugin : AbstractExportPlugin <ApertureExportPlugIn>
{
	// The cached API Manager object, as passed to the -initWithAPIManager: method.
	id _apiManager; 
	
	// The cached Aperture Export Manager object - you should fetch this from the API Manager during -initWithAPIManager:
	NSObject<ApertureExportManager, PROAPIObject> *_exportManager; 
	
	// The lock used to protect all access to the ApertureExportProgress structure
	NSLock						*_progressLock;
	
	// Top-level objects in the nib are automatically retained - this array
	// tracks those, and releases them
//	NSArray						*_topLevelNibObjects;
	
	// The structure used to pass all progress information back to Aperture
	ApertureExportProgress		exportProgress;

	// Outlets to your plug-ins user interface
//	IBOutlet NSView				*settingsView;
//	IBOutlet NSView				*firstView;
//	IBOutlet NSView				*lastView;
	
//	IBOutlet NSTextField		*usernameTextField;
//	IBOutlet NSTextField		*passwordTextField;
	
//	IBOutlet NSPopUpButton		*albumsPopUpButton;
//	IBOutlet NSTokenField		*tagsTokenField;
	
//	IBOutlet NSArrayController	*albumController;
	
//	NSOperationQueue			*operationQueue;
//	NSMutableArray				*uploadOperations;

//	NSString					*exportBasePath;
//	NSMutableArray				*exportedImagePaths;
	
//	BOOL						exportCanceled;
	
//	NSMutableDictionary			*session;
//	NSArray						*albums;
}

//@property (nonatomic, readonly) NSMutableDictionary *session;
//@property (nonatomic, readonly) NSArray *albums;
//
//- (IBAction)loginButtonPressed:(id)sender;

@end
