//
//  iPhotoExportPlugin.h
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/22/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AbstractExportPlugin.h"
#import "ExportPluginProtocol.h"
#import "ExportMgr.h"

@interface iPhotoExportPlugin : AbstractExportPlugin <ExportPluginProtocol> 
{
//	IBOutlet id firstView;
//	IBOutlet id lastView;
    IBOutlet NSBox		*settingsBox;
    ExportMgr			*_exportManager;
	
	NSLock				*progressLock;
	CDStruct_e5bf5178	progress;
}

@end
