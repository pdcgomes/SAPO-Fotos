//
//  IPHSAPOFotosSettingsController.h
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/24/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IPHPluginSettingsProtocol-Protocol.h"


@interface IPHSAPOFotosSettingsController : NSObject<IPHPluginSettingsProtocol> 
{
	IBOutlet NSPanel	*_settingsPanel;
	IBOutlet NSPanel	*_advancedSettingsPanel;
}

- (id)initFromPlugin:(id)plugin withManager:(id)manager;

@end
