//
//  iPhotoPublishPlugin.h
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/23/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IPHPublishServiceProtocol-Protocol.h"

@class IPPublishPluginManager;

@interface IPHSAPOFotosPlugin : NSObject <IPHPublishServiceProtocol>
{
	IPPublishPluginManager	*publishManager;
}

@end
