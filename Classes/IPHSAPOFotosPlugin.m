//
//  iPhotoPublishPlugin.m
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/23/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <objc/runtime.h>
#import "IPHSAPOFotosPlugin.h"
#import "IPPublishPluginManager.h"

@implementation IPHSAPOFotosPlugin

- (void)dealloc
{
	TRACE(@"");
	[publishManager release];
	[super dealloc];
}
#pragma mark -
#pragma mark IPHPublishServiceProtocol

+ (id)serviceKey
{
//	return @"IPHPublishServiceFlickr";
	return @"IPHPublishServiceSAPOFotos";
}

+ (id)serviceName
{
	TRACE(@"");
//	return @"flickr";
	return @"sapofotos";
}

+ (id)shortServiceName
{
	TRACE(@"");
//	return @"flickr";
	return @"sapofotos";
}

+ (int)servicePriority
{
	TRACE(@"");
	return 0;
}

+ (id)containerLabel
{
	TRACE(@"");
	return @"SAPO Fotos";
}
+ (id)sectionLabel
{
	TRACE(@"");
	return @"SAPOFOTOS";
}
+ (id)albumLabel
{
	TRACE(@"");
	return nil;
}

+ (id)toolbarLabel:(BOOL)arg1
{
	TRACE(@"");
	return @"SAPO Fotos";
}
+ (id)toolbarTooltip:(BOOL)arg1
{
	TRACE(@"");
	return @"Publish selected photos as a new album to SAPO Fotos";
}
+ (id)menuItemLabel:(BOOL)arg1
{
	TRACE(@"");
	return @"SAPO Fotos";
}
+ (id)menuItemTooltip:(BOOL)arg1
{
	TRACE(@"");
	return @"SAPO Fotos";	
}

+ (id)sizedIcon:(int)arg1
{
	NSString *iconName = nil;
	switch(arg1)
	{
		case 1: iconName = @"sl-icon-sapofotos.tiff"; break;
		case 2: iconName = @"tools_org-publish_sapofotos.tiff"; break;
		default: iconName = @"sl-icon-small_sapofotos.tiff"; break;
	}
	TRACE(@"sizedIcon: %d", arg1);
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *iconPath = [bundle pathForImageResource:iconName];
	TRACE(@"IconPath: %@", iconPath);
	return [[[NSImage alloc] initWithContentsOfFile:iconPath] autorelease];
}

+ (id)protectionUsername:(id)arg1
{
	TRACE(@"");
	return nil;	
}

+ (void)setProtectionUsername:(id)arg1 withSettings:(id)arg2
{
	TRACE(@"");
	
}

+ (int)showCaptionsSetting:(id)arg1
{
	TRACE(@"");
	return 0;
}

+ (int)photoSizeSetting:(id)arg1
{
	TRACE(@"");
	return 0;
}

+ (id)contributionEmailAddress:(id)arg1
{
	TRACE(@"");
	return nil;
}
+ (BOOL)allowsContributions:(id)arg1
{
	TRACE(@"");
	return NO;
}

+ (BOOL)infoSettingsDiffer:(id)arg1 withSettings:(id)arg2
{
	TRACE(@"");
	return NO;
}

+ (BOOL)protectionSettingsDiffer:(id)arg1 withSettings:(id)arg2
{
	TRACE(@"");
	return NO;
}

+ (BOOL)photoSizeSettingsDiffer:(id)arg1 withSettings:(id)arg2
{
	TRACE(@"");
	return NO;	
}

+ (BOOL)supportsDistantPhotoUpdates
{
	TRACE(@"");
	return NO;	
}

+ (BOOL)supportsDistantMetadataUpdates
{
	TRACE(@"");
	return NO;	
}

+ (BOOL)supportsSourceGUID
{
	TRACE(@"");
	return NO;	
}

+ (BOOL)supportsAuthenticatedGETs
{
	TRACE(@"");
	return NO;	
}

+ (BOOL)supportsVideoClips
{
	TRACE(@"");
	return NO;	
}

+ (BOOL)supportsUserOrderNatively
{
	TRACE(@"");
	return NO;	
}

+ (BOOL)permissionsAppliedPerPhotoNotPerAlbum
{
	TRACE(@"");
	return NO;
}
+ (unsigned int)maximumPhotoCount
{
	TRACE(@"");
	return 100;
}

+ (id)iLMBServiceName
{
	TRACE(@"");
	return @"sapofotos";
}

+ (id)propertiesForLocation:(id)arg1 withUsername:(id)arg2
{
	TRACE(@"");
	return nil;
}

+ (id)oldServiceKey
{
	TRACE(@"");
	return @"sapofotos";
}

+ (id)serviceUsername:(id)arg1
{
	TRACE(@"");
	return nil;
}
- (id)serviceKey
{
	TRACE(@"");
	return @"sapofotos";	
}

- (id)initWithManager:(id)arg1
{
	TRACE(@"Arg: %@", arg1);
	if((self = [super init])) {
		publishManager = [arg1 retain];
		[publishManager initializePlugin:self];
		[self performSelector:@selector(logPluginClasses) withObject:nil afterDelay:5.0];
	}
	return self;
}

- (void)logPluginClasses
{
	NSArray *pluginClasses = [publishManager allPluginClasses];
//	TRACE(@"%@", pluginClasses);
	for(Class class in pluginClasses) {
		TRACE(@"ServiceDescriptions:\n"
			  @"ServiceKey: <%@>\n"
			  @"ServiceName: <%@>\n"
			  @"ShortServiceName: <%@>\n"
			  @"ServicePriority: <%d>\n"
			  @"ContainerLabel: <%@>\n"
			  @"SectionLabel: <%@>\n"
			  @"MenuItemLabel: <%@>\n"
			  @"SizedIcon: <%@>\n"
			  @"IconName: <%@>",
			  [class serviceKey],
			  [class serviceName],
			  [class shortServiceName],
			  [class servicePriority],
			  [class containerLabel],
			  [class sectionLabel],
			  [class menuItemLabel:YES],
			  [class sizedIcon:0], 
			  [[class sizedIcon:0] name]);
	}
	
	Ivar pluginsIvar = class_getInstanceVariable(NSClassFromString(@"IPPublishPluginManager"), "_plugins");
	NSMutableArray *loadedPlugins = object_getIvar(publishManager, pluginsIvar);
	
	for(NSString *serviceKey in loadedPlugins) {
		id plugin = [publishManager pluginForServiceKey:serviceKey];
		TRACE(@"Plugin: %@", plugin);
	}
}

- (id)manager
{
	TRACE(@"");
	return nil;
}

- (void)setParentOperation:(id)arg1
{
	TRACE(@"");
}

- (id)parentOperation
{
	TRACE(@"");
	return nil;
}

- (id)settingsController
{
	TRACE(@"");
	return nil;
}

- (void)beginSettingsInWindow:(id)arg1 withSettings:(id)arg2 modalDelegate:(id)arg3 didEndSelector:(SEL)arg4 contextInfo:(void *)arg5 embedded:(id)arg6 forceLogin:(BOOL)arg7
{
	TRACE(@"");
	
}

- (id)settings
{
	TRACE(@"");
	return nil;
}

- (id)initializeGlobalSettings
{
	TRACE(@"");
	return nil;
}

- (id)globalSettings
{
	TRACE(@"");
	return nil;
}

- (void)setGlobalSettings:(id)arg1
{
	TRACE(@"");
}

- (id)globalSettingForKey:(id)arg1
{
	TRACE(@"");
	return nil;
}

- (void)setGlobalSetting:(id)arg1 forKey:(id)arg2
{
	TRACE(@"");
	
}

- (BOOL)validateCredentials
{
	TRACE(@"");
	return NO;
}

- (void)setUsername:(id)arg1 setPassword:(id)arg2
{
	TRACE(@"");
}

- (id)username
{
	TRACE(@"");
	return nil;
}

- (id)password
{
	TRACE(@"");
	return nil;	
}

- (id)serviceUsername
{
	TRACE(@"");
	return nil;	
}

- (void)setServiceUsername:(id)arg1
{
	TRACE(@"%@", arg1);
}

- (id)defaultUsername
{
	TRACE(@"");
	return nil;	
}

- (void)setDefaultUsername:(id)arg1
{
	TRACE(@"");
	
}

- (id)displayName
{
	TRACE(@"");
	return nil;	
}

- (void)setDisplayName:(id)arg1
{
	TRACE(@"");
	
}

- (id)error
{
	TRACE(@"");
	return nil;	
}

- (void)setError:(id)arg1
{
	TRACE(@"");
	
}

- (id)baseURL
{
	TRACE(@"");
	return nil;	
}

- (void)setBaseURL:(id)arg1
{
	TRACE(@"");
	
}

- (id)path
{
	TRACE(@"");
	return nil;	
}

- (void)setPath:(id)arg1
{
	TRACE(@"");
	
}

- (id)directoryName
{
	TRACE(@"");
	return nil;	
}

- (void)setDirectoryName:(id)arg1
{
	TRACE(@"");
	
}

- (id)dataFileName
{
	TRACE(@"");
	return nil;	
}

- (void)setDataFileName:(id)arg1
{
	TRACE(@"");
	
}

- (id)subscribeURL
{
	TRACE(@"");
	return nil;	
}

- (void)setSubscribeURL:(id)arg1
{
	TRACE(@"");
	
}

- (id)authenticationDomain
{
	TRACE(@"");
	return nil;	
}

- (void)setAuthenticationDomain:(id)arg1
{
	TRACE(@"");
	
}

- (id)rootNameForPhoto:(id)arg1
{
	TRACE(@"");
	return nil;	
}

- (id)rootPathForPhoto:(id)arg1
{
	TRACE(@"");
	return nil;
}

- (id)imageNameForPhoto:(id)arg1
{
	TRACE(@"");
	return nil;	
}

- (id)imagePathForPhoto:(id)arg1
{
	TRACE(@"");
	return nil;	
}

- (id)thumbnailNameForPhoto:(id)arg1
{
	TRACE(@"");
	return nil;	
}
- (id)thumbnailPathForPhoto:(id)arg1
{
	TRACE(@"");
	return nil;	
}
- (id)originalNameForPhoto:(id)arg1
{
	TRACE(@"");
	return nil;	
}
- (id)originalPathForPhoto:(id)arg1
{
	TRACE(@"");
	return nil;	
}
- (BOOL)initSession
{
	TRACE(@"");
	return YES;	
}
- (BOOL)readDistantAlbumIntoDB:(id)arg1 forLocalAlbum:(id)arg2
{
	TRACE(@"");
	return NO;	
}
- (void)createDistantAlbumWithUUID:(id)arg1
{
	TRACE(@"");
}
- (BOOL)deleteDistantAlbum:(id)arg1
{
	TRACE(@"");
	return NO;	
}
- (void)matchLocalPhoto:(id)arg1 toDistantPhoto:(id)arg2
{
	TRACE(@"");
}
- (id)photoPropertiesFromXML:(id)arg1 downloadedAtURL:(id)arg2
{
	TRACE(@"");
	return nil;	
}
- (void)createDistantPhotoFromLocalPhoto:(id)arg1
{
	TRACE(@"");
}
- (BOOL)deleteDistantPhoto:(id)arg1 size:(int)arg2
{
	TRACE(@"");
	return NO;	
}
- (void)updateDistantPropertiesFromLocalPhoto:(id)arg1
{
	TRACE(@"");
}
- (void)updateLocalPropertiesFromDistantPhoto:(id)arg1
{
	TRACE(@"");
}
- (id)prepareDistantImageFromLocalPhoto:(id)arg1 size:(int)arg2
{
	return nil;
	TRACE(@"");
}
- (BOOL)updateDistantImageFromLocalPhoto:(id)arg1 size:(int)arg2 contextInfo:(id)arg3
{
	return NO;
	TRACE(@"");
}
- (void)updateExistingSizes:(int)arg1 forPhoto:(id)arg2
{
	TRACE(@"");
}
- (id)getDistantPhoto:(id)arg1 size:(int)arg2
{
	return nil;
	TRACE(@"");
}
- (void)updateDistantAlbumProperties
{
	TRACE(@"");
}
- (void)updateLocalAlbumProperties
{
	TRACE(@"");
}
- (BOOL)setUpContributionAddress:(int)arg1
{
	return NO;
	TRACE(@"");
}
- (void)updatePublishPermissions
{
	TRACE(@"");
}
- (BOOL)hasPendingOperations:(BOOL)arg1
{
	return NO;
	TRACE(@"");
}
- (id)processPendingOperations:(BOOL)arg1
{
	return nil;
	TRACE(@"");
}
- (void)concludeOperation
{
	TRACE(@"");
}
- (void)abortOperation
{
	TRACE(@"");
}
- (void)cleanupOperation
{
	TRACE(@"");
}
- (void)listPublishedAlbumsToTarget:(id)arg1 selector:(SEL)arg2 contextInfo:(id)arg3
{
	TRACE(@"");
}
- (void)listContentsOfPublishedAlbum:(id)arg1 toTarget:(id)arg2 selector:(SEL)arg3 contextInfo:(id)arg4
{
	TRACE(@"");
}

@end
