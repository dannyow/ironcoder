/*
	File:		iTunesXPlugIn.c

	Contains:	visual plug-in for iTunes on Mac OS X
        
	Written by: 	Developer Technical Support

	Copyright:	Copyright � 2001 by Apple Computer, Inc., All Rights Reserved.

			You may incorporate this Apple sample source code into your program(s) without
			restriction. This Apple sample source code has been provided "AS IS" and the
			responsibility for its operation is yours. You are not permitted to redistribute
			this Apple sample source code as "Apple sample source code" after having made
			changes. If you're going to re-distribute the source, we require that you make
			it clear in the source that the code was descended from Apple sample source
			code, but that you've made changes.

	Change History (most recent first):
                        6/6/01	   KG	   moved to project builder on Mac OS X
                        4/17/01    DTS     first checked in.
*/

/**\
|**|	conditional compilation directives
\**/

#define QDMP_FLAG	1 	// 0 != use direct pixmap access

/**\
|**|	includes
\**/

#include "QDMP.h"
#include "iTunesVisualAPI.h"

/**\
|**|	typedef's, struct's, enum's, etc.
\**/

#define kTVisualPluginName                      "\pEmily Dickinson Keywords"
#define	kTVisualPluginCreator			'hook'

#define	kTVisualPluginMajorVersion		1
#define	kTVisualPluginMinorVersion		0
#define	kTVisualPluginReleaseStage		finalStage
#define	kTVisualPluginNonFinalRelease	0

#include "GlueJunk.h"

enum
{
        kColorSettingID=3,
	kFlashSettingID=4,
        kOKSettingID=5
};

typedef struct VisualPluginData {
	void *				appCookie;
	ITAppProcPtr			appProc;

	ITFileSpec			pluginFileSpec;
	
	CGrafPtr			destPort;
	Rect				destRect;
	OptionBits			destOptions;
	UInt32				destBitDepth;

	RenderVisualData		renderData;
	UInt32				renderTimeStampID;
	
	ITTrackInfo			trackInfo;
	ITStreamInfo			streamInfo;

	Boolean				playing;
	Boolean				padding[3];

//	Plugin-specific data
	UInt8				minLevel[kVisualMaxDataChannels];		// 0-128
	UInt8				maxLevel[kVisualMaxDataChannels];		// 0-128

	UInt8				min,max;

	GWorldPtr			offscreen;
} VisualPluginData;



#if QDMP_FLAG
#define SET_PIXEL(pm,h,v,c) \
			QDMP_Set_Pixel(pm,h,v,c);
#else
#define SET_PIXEL(pm,h,v,c) \
			{ RGBForeColor(c);MoveTo(h,v);Line(1,0);}
#endif

/**\
|**|	local (static) globals
\**/

static Boolean	gColorFlag = true;
static Boolean	gFlashFlag = false;

static CGrafPtr	gSavePort;
static GDHandle	gSaveDevice;
static SInt16	gLine = 0;

/**\
|**|	exported function prototypes
\**/

extern OSStatus iTunesPluginMainMachO(OSType message,PluginMessageInfo *messageInfo,void *refCon);

/**\
|**|	static functions
\**/

//	MemClear
static void MemClear(LogicalAddress dest,SInt32 length)
{
	register unsigned char	*ptr;

	ptr = (unsigned char*) dest;
	
	while (length-- > 0)
		*ptr++ = 0;
}

// ProcessRenderData

static void ProcessRenderData(VisualPluginData *visualPluginData,const RenderVisualData *renderData)
{
	SInt16		index;
	SInt32		channel;

	if (renderData == nil)
	{
		MemClear(&visualPluginData->renderData,sizeof(visualPluginData->renderData));
		return;
	}

	visualPluginData->renderData = *renderData;
	
	for (channel = 0;channel < renderData->numSpectrumChannels;channel++)
	{
		visualPluginData->minLevel[channel] = 
			visualPluginData->maxLevel[channel] = 
			renderData->spectrumData[channel][0];

		for (index = 1; index < kVisualNumSpectrumEntries; index++)
		{
			UInt8		value;
			
			value = renderData->spectrumData[channel][index];

			if (value < visualPluginData->minLevel[channel])
				visualPluginData->minLevel[channel] = value;
			else if (value > visualPluginData->maxLevel[channel])
				visualPluginData->maxLevel[channel] = value;
		}
	}
}

// GetPortCopyBitsBitMap
//
static BitMap* GetPortCopyBitsBitMap(CGrafPtr port)
{
	BitMap*		destBMap;

#if ACCESSOR_CALLS_ARE_FUNCTIONS
	destBMap = (BitMap*)GetPortBitMapForCopyBits(port);
#else
  #if OPAQUE_TOOLBOX_STRUCTS
	PixMapHandle	pixMap;
	
	pixMap		= GetPortPixMap(port);
	destBMap	= (BitMap*) (*pixMap);
  #else
	destBMap	= (BitMap*) &((GrafPtr)port)->portBits;
  #endif
#endif
	return destBMap;
}

static const RGBColor gLandColors[] = {
	{0x0000,0x0000,0x4000},	// dark blue
	{0x4000,0x4000,0xC000},	// lite blue

	{0x0000,0x8000,0x0000},	// green
	{0x4000,0xC000,0x4000},	// lite green
	{0xB000,0x6000,0x4000},	// brown

	{0x8000,0x4000,0x2000},	// dark brown
	{0x4000,0x4000,0x4000},	// gray
	{0xC000,0xC000,0xC000}	// lt gray
};

static void UInt8ToColorRGB(const UInt8 pValue,RGBColor* pRGBColorPtr)
{
	if (nil == pRGBColorPtr)
		return;

	if (gColorFlag)
	{
		UInt8 hiValue = pValue / 32;
		UInt8 nextValue = (hiValue + 1);

		if (nextValue >= 8) nextValue = hiValue;

		*pRGBColorPtr = QDMP_Mix_RGBColors(gLandColors[hiValue],gLandColors[nextValue],pValue / 32.0f);
	}
	else
	{
		pRGBColorPtr->red = pRGBColorPtr->green = pRGBColorPtr->blue = (pValue << 8) + pValue;
	}
}

static void _Erase(VisualPluginData *visualPluginData,CGrafPtr destPort,const Rect *destRect,Boolean onlyUpdate)
{
        #pragma unused(visualPluginData,destPort,destRect,onlyUpdate)
	GetGWorld(&gSavePort,&gSaveDevice);
}

static void _Draw(VisualPluginData *visualPluginData,CGrafPtr destPort,const Rect *destRect,Boolean onlyUpdate)
{
	Rect		srcRect;
    
    //doSomething();
    
	if ((nil == destPort) || (nil == destRect) ||
		(nil == visualPluginData->offscreen))
		return;

	srcRect	= *destRect;
	OffsetRect(&srcRect,-srcRect.left,-srcRect.top);

	if (false == onlyUpdate)
	{
		PixMapHandle	pixMapHdl = GetGWorldPixMap(visualPluginData->offscreen);

		if (!pixMapHdl || !*pixMapHdl)
			return;

		SetGWorld(visualPluginData->offscreen,nil);

		gLine++;
		if ((gLine < srcRect.top) || (gLine >= srcRect.bottom))
			gLine = srcRect.top;

		// Update our offscreen pixmap
		if (gFlashFlag)
		{
			RGBColor	foreColor;
			Rect		tRect = srcRect;

			if (gColorFlag)
				UInt8ToColorRGB(visualPluginData->maxLevel[1],&foreColor);
			else
			{
				foreColor.red = foreColor.green = ((UInt16) visualPluginData->maxLevel[1] << 9);
				foreColor.blue = ((UInt16)visualPluginData->maxLevel[0] << 9);
			}

			RGBForeColor(&foreColor);

			tRect.bottom = (tRect.top = gLine) + 1;

			PaintRect(&tRect);
		}
		else
		{
			SInt16 dataWidth = kVisualNumSpectrumEntries;
			SInt16 halfWidth = dataWidth / 2;
			SInt16 screenWidth = (srcRect.right - srcRect.left);
			SInt16 minData = visualPluginData->minLevel[0];
			SInt16 maxData = visualPluginData->maxLevel[0];
			RGBColor tRGBColor;
			SInt16 col,fraction = 0,index = 0;

			if (minData < visualPluginData->min)
				visualPluginData->min = minData;
			else if (minData > visualPluginData->min)
				minData = visualPluginData->min++;

			if (maxData > visualPluginData->max)
				visualPluginData->max = maxData;
			else if (maxData < visualPluginData->max)
				maxData = visualPluginData->max;

			if (dataWidth > screenWidth)
			{
				for (col = srcRect.left;col < srcRect.right;col++)
				{
					SInt16 count = 0;
					SInt16 total = 0;

					while (fraction < dataWidth)
					{
						if (index <= halfWidth)
							total += visualPluginData->renderData.spectrumData[0][index];
						else
							total += visualPluginData->renderData.spectrumData[1][dataWidth - index];

						index++;
						fraction += screenWidth;
						count++;
					}
					fraction -= dataWidth;	// fix overflow
					total /= count;					

					total = (total - minData) * 255 / (maxData - minData);
					UInt8ToColorRGB(total,&tRGBColor);
					SET_PIXEL(pixMapHdl,col,gLine,&tRGBColor);
				}
			}
			else	// screenWidth > dataWidth
			{
				fraction = screenWidth - dataWidth;	// force overflow the first time

				for (col = srcRect.left;col < srcRect.right;col++)
				{
					fraction += dataWidth;
					if (fraction >= screenWidth)	// overflow
					{
						SInt16 level;

						fraction -= screenWidth;	// fix overflow

						if (index <= halfWidth)
							level = visualPluginData->renderData.spectrumData[0][index];
						else
							level = visualPluginData->renderData.spectrumData[1][dataWidth - index];

						index++;
						level = (level - minData) * 255 / (maxData - minData);
						UInt8ToColorRGB(level,&tRGBColor);
					}

					SET_PIXEL(pixMapHdl,col,gLine,&tRGBColor);
				}
			}
		}
	}
}

static void _Filter(VisualPluginData *visualPluginData,CGrafPtr destPort,const Rect *destRect,Boolean onlyUpdate)
{
	BitMap*		srcBitMap;
	BitMap*		dstBitMap;
	Rect		srcRect = *destRect;
	Rect		dstRect = srcRect;

	#pragma unused(onlyUpdate)

	if ((destPort == nil) || (visualPluginData->offscreen == nil))
		return;

	OffsetRect(&srcRect,-srcRect.left,-srcRect.top);

	srcBitMap	= GetPortCopyBitsBitMap(visualPluginData->offscreen);
	dstBitMap	= GetPortCopyBitsBitMap(destPort);

	SetGWorld(destPort,nil);

	ForeColor(blackColor);
	BackColor(whiteColor);

	srcRect.bottom = (srcRect.top += gLine) + 1;
	dstRect.bottom = (dstRect.top += gLine) + 1;

	CopyBits(srcBitMap,dstBitMap,&srcRect,&dstRect,srcCopy,nil);

	SetGWorld(gSavePort,gSaveDevice);
}

/*
	RenderVisualPort
*/
static void RenderVisualPort(VisualPluginData *visualPluginData,CGrafPtr destPort,const Rect *destRect,Boolean onlyUpdate)
{
	_Erase(visualPluginData,destPort,destRect,onlyUpdate);
	_Draw(visualPluginData,destPort,destRect,onlyUpdate);
	_Filter(visualPluginData,destPort,destRect,onlyUpdate);
}

/*
	AllocateVisualData is where you should allocate any information that depends
	on the port or rect changing (like offscreen GWorlds).
*/

static OSStatus AllocateVisualData(VisualPluginData *visualPluginData,CGrafPtr destPort,const Rect *destRect)
{
	OSStatus		status;
	Rect			allocateRect;

	(void) destPort;

	GetGWorld(&gSavePort,&gSaveDevice);
	
	allocateRect = *destRect;
	OffsetRect(&allocateRect,-allocateRect.left,-allocateRect.top);
				
	status = NewGWorld(&visualPluginData->offscreen,32,&allocateRect,nil,nil,useTempMem);
	if (status == noErr)
	{
		PixMapHandle	pix = GetGWorldPixMap(visualPluginData->offscreen);

		LockPixels(pix);

		// Offscreen starts out black
		SetGWorld(visualPluginData->offscreen,nil);
		
		ForeColor(blackColor);
		PaintRect(&allocateRect);
	}

	SetGWorld(gSavePort,gSaveDevice);
	
	return status;
}

/*
	DeallocateVisualData is where you should deallocate the .
*/
static void DeallocateVisualData(VisualPluginData *visualPluginData)
{
	if (visualPluginData->offscreen != nil)
	{
		DisposeGWorld(visualPluginData->offscreen);
		visualPluginData->offscreen = nil;
	}
}

// ChangeVisualPort
//
static OSStatus ChangeVisualPort(VisualPluginData *visualPluginData,CGrafPtr destPort,const Rect *destRect)
{
	OSStatus		status;
	Boolean			doAllocate;
	Boolean			doDeallocate;
	
	status = noErr;
	
	doAllocate		= false;
	doDeallocate	= false;
		
	if (destPort != nil)
	{
		if (visualPluginData->destPort != nil)
		{
			if (false == EqualRect(destRect,&visualPluginData->destRect))
			{
				doDeallocate	= true;
				doAllocate		= true;
			}
		}
		else
		{
			doAllocate = true;
		}
	}
	else
	{
		doDeallocate = true;
	}
	
	if (doDeallocate)
		DeallocateVisualData(visualPluginData);
	
	if (doAllocate)
		status = AllocateVisualData(visualPluginData,destPort,destRect);

	if (status != noErr)
		destPort = nil;

	visualPluginData->destPort = destPort;
	if (destRect != nil)
		visualPluginData->destRect = *destRect;

	return status;
}

/*
	ResetRenderData
*/
static void ResetRenderData(VisualPluginData *visualPluginData)
{
	MemClear(&visualPluginData->renderData,sizeof(visualPluginData->renderData));

	visualPluginData->minLevel[0] = 
		visualPluginData->minLevel[1] =
		visualPluginData->maxLevel[0] =
		visualPluginData->maxLevel[1] = 0;
}

/* 
	settingsControlHandler
*/
pascal OSStatus settingsControlHandler(EventHandlerCallRef inRef,EventRef inEvent, void* userData)
{
    WindowRef wind=NULL;
    ControlID controlID;
    ControlRef control=NULL;
    //get control hit by event
    GetEventParameter(inEvent,kEventParamDirectObject,typeControlRef,NULL,sizeof(ControlRef),NULL,&control);
    wind=GetControlOwner(control);
    GetControlID(control,&controlID);
    switch(controlID.id){
        case kColorSettingID:
                gColorFlag=GetControlValue(control);
                break;
        case kFlashSettingID:
                gFlashFlag=GetControlValue(control);
                break;
        case kOKSettingID:
                HideWindow(wind);
                break;
    }
    return noErr;
}
/*
	VisualPluginHandler
*/
static OSStatus VisualPluginHandler(OSType message,VisualPluginMessageInfo *messageInfo,void *refCon)
{
    LEVisualPluginHandler(message, messageInfo, refCon);
    
	OSStatus			status;
	VisualPluginData *	visualPluginData;

	visualPluginData = (VisualPluginData*) refCon;
	
	status = noErr;

	switch (message)
	{
		/*
			Sent when the visual plugin is registered.  The plugin should do minimal
			memory allocations here.  The resource fork of the plugin is still available.
		*/		
		case kVisualPluginInitMessage:
		{
			visualPluginData = (VisualPluginData*) NewPtrClear(sizeof(VisualPluginData));
			if (visualPluginData == nil)
			{
				status = memFullErr;
				break;
			}

			visualPluginData->appCookie	= messageInfo->u.initMessage.appCookie;
			visualPluginData->appProc	= messageInfo->u.initMessage.appProc;

			/* Remember the file spec of our plugin file. We need this so we can open our resource fork during */
			/* the configuration message */
			
			status = PlayerGetPluginFileSpec(visualPluginData->appCookie,visualPluginData->appProc,&visualPluginData->pluginFileSpec);

			messageInfo->u.initMessage.refCon	= (void*) visualPluginData;
			break;
		}
			
		/*
			Sent when the visual plugin is unloaded
		*/		
		case kVisualPluginCleanupMessage:
			if (visualPluginData != nil)
				DisposePtr((Ptr)visualPluginData);
			break;
			
		/*
			Sent when the visual plugin is enabled.  iTunes currently enables all
			loaded visual plugins.  The plugin should not do anything here.
		*/
		case kVisualPluginEnableMessage:
		case kVisualPluginDisableMessage:
			break;

		/*
			Sent if the plugin requests idle messages.  Do this by setting the kVisualWantsIdleMessages
			option in the RegisterVisualMessage.options field.
		*/
		case kVisualPluginIdleMessage:
            /* if (false == visualPluginData->playing)
				RenderVisualPort(visualPluginData,visualPluginData->destPort,&visualPluginData->destRect,false); */
			break;
					
		/*
			Sent if the plugin requests the ability for the user to configure it.  Do this by setting
			the kVisualWantsConfigure option in the RegisterVisualMessage.options field.
		*/
		case kVisualPluginConfigureMessage:
                       {
                            static EventTypeSpec controlEvent={kEventClassControl,kEventControlHit};
                            static const ControlID kColorSettingControlID={'cbox',kColorSettingID};
                            static const ControlID kFlashSettingControlID={'cbox',kFlashSettingID};
                            
                            static WindowRef settingsDialog=NULL;
                            static ControlRef color=NULL;
                            static ControlRef flash=NULL;
                            
//                          printf("before getting dialog");
                            
                            if(settingsDialog==NULL){
                                IBNibRef 		nibRef;
                                //we have to find our bundle to load the nib inside of it
                                
                                
                                CFBundleRef iTunesXPlugin;
                                
                                iTunesXPlugin=CFBundleGetBundleWithIdentifier(CFSTR("Emily Dickinson Keywords.bundle"));
                                if (iTunesXPlugin == NULL) SysBeep(2);
                             
                                CreateNibReferenceWithCFBundle(iTunesXPlugin,CFSTR("SettingsDialog"), &nibRef);
                                 
                                CreateWindowFromNib(nibRef, CFSTR("PluginSettings"), &settingsDialog);
                                DisposeNibReference(nibRef);
                                InstallWindowEventHandler(settingsDialog,NewEventHandlerUPP(settingsControlHandler),
                                                    1,&controlEvent,0,NULL);
                                GetControlByID(settingsDialog,&kColorSettingControlID,&color);
                                GetControlByID(settingsDialog,&kFlashSettingControlID,&flash);
                            }
                            SetControlValue(color,gColorFlag);
                            SetControlValue(flash,gFlashFlag);
                            ShowWindow(settingsDialog);
                        }break;
		/*
			Sent when iTunes is going to show the visual plugin in a port.  At
			this point,the plugin should allocate any large buffers it needs.
		*/
		case kVisualPluginShowWindowMessage:
            /*
			visualPluginData->destOptions = messageInfo->u.showWindowMessage.options;

			status = ChangeVisualPort(	visualPluginData,
										messageInfo->u.showWindowMessage.port,
										&messageInfo->u.showWindowMessage.drawRect);
			if (status == noErr)
				RenderVisualPort(visualPluginData,visualPluginData->destPort,&visualPluginData->destRect,true);
                */
			break;
			
		/*
			Sent when iTunes is no longer displayed.
		*/
		case kVisualPluginHideWindowMessage:
            /*
			(void) ChangeVisualPort(visualPluginData,nil,nil);

			MemClear(&visualPluginData->trackInfo,sizeof(visualPluginData->trackInfo));
			MemClear(&visualPluginData->streamInfo,sizeof(visualPluginData->streamInfo));
            */
			break;
		
		/*
			Sent when iTunes needs to change the port or rectangle of the currently
			displayed visual.
		*/
		case kVisualPluginSetWindowMessage:
            /*
			visualPluginData->destOptions = messageInfo->u.setWindowMessage.options;

			status = ChangeVisualPort(	visualPluginData,
										messageInfo->u.setWindowMessage.port,
										&messageInfo->u.setWindowMessage.drawRect);

			if (status == noErr)
				RenderVisualPort(visualPluginData,visualPluginData->destPort,&visualPluginData->destRect,true);
            */
			break;
		
		/*
			Sent for the visual plugin to render a frame.
		*/
		case kVisualPluginRenderMessage:
            /*
			visualPluginData->renderTimeStampID	= messageInfo->u.renderMessage.timeStampID;

			ProcessRenderData(visualPluginData,messageInfo->u.renderMessage.renderData);
				
			RenderVisualPort(visualPluginData,visualPluginData->destPort,&visualPluginData->destRect,false);
            */
			break;
#if 0			
		/*
			Sent for the visual plugin to render directly into a port.  Not necessary for normal
			visual plugins.
		*/
		case kVisualPluginRenderToPortMessage:
			status = unimpErr;
			break;
#endif 0
		/*
			Sent in response to an update event.  The visual plugin should update
			into its remembered port.  This will only be sent if the plugin has been
			previously given a ShowWindow message.
		*/	
		case kVisualPluginUpdateMessage:
			//RenderVisualPort(visualPluginData,visualPluginData->destPort,&visualPluginData->destRect,true);
			break;
		
		/*
			Sent when the player starts.
		*/
		case kVisualPluginPlayMessage:
            /*
			if (messageInfo->u.playMessage.trackInfo != nil)
				visualPluginData->trackInfo = *messageInfo->u.playMessage.trackInfo;
			else
				MemClear(&visualPluginData->trackInfo,sizeof(visualPluginData->trackInfo));

			if (messageInfo->u.playMessage.streamInfo != nil)
				visualPluginData->streamInfo = *messageInfo->u.playMessage.streamInfo;
			else
				MemClear(&visualPluginData->streamInfo,sizeof(visualPluginData->streamInfo));
		
			visualPluginData->playing = true;
            */
			break;

		/*
			Sent when the player changes the current track information.  This
			is used when the information about a track changes,or when the CD
			moves onto the next track.  The visual plugin should update any displayed
			information about the currently playing song.
		*/
		case kVisualPluginChangeTrackMessage:
            /*
			if (messageInfo->u.changeTrackMessage.trackInfo != nil)
				visualPluginData->trackInfo = *messageInfo->u.changeTrackMessage.trackInfo;
			else
				MemClear(&visualPluginData->trackInfo,sizeof(visualPluginData->trackInfo));

			if (messageInfo->u.changeTrackMessage.streamInfo != nil)
				visualPluginData->streamInfo = *messageInfo->u.changeTrackMessage.streamInfo;
			else
				MemClear(&visualPluginData->streamInfo,sizeof(visualPluginData->streamInfo));
            */
			break;

		/*
			Sent when the player stops.
		*/
		case kVisualPluginStopMessage:
            /*
			visualPluginData->playing = false;
			
			ResetRenderData(visualPluginData);

			RenderVisualPort(visualPluginData,visualPluginData->destPort,&visualPluginData->destRect,true);
            */
			break;
		
		/*
			Sent when the player changes position.
		*/
		case kVisualPluginSetPositionMessage:
			break;

		/*
			Sent when the player pauses.  iTunes does not currently use pause or unpause.
			A pause in iTunes is handled by stopping and remembering the position.
		*/
		case kVisualPluginPauseMessage:
            /*
			visualPluginData->playing = false;

			ResetRenderData(visualPluginData);

			RenderVisualPort(visualPluginData,visualPluginData->destPort,&visualPluginData->destRect,true);
            */
			break;
			
		/*
			Sent when the player unpauses.  iTunes does not currently use pause or unpause.
			A pause in iTunes is handled by stopping and remembering the position.
		*/
		case kVisualPluginUnpauseMessage:
			//visualPluginData->playing = true;
			break;
		
		/*
			Sent to the plugin in response to a MacOS event.  The plugin should return noErr
			for any event it handles completely,or an error (unimpErr) if iTunes should handle it.
		*/
		case kVisualPluginEventMessage:
            /*
			{
				EventRecord* tEventPtr = messageInfo->u.eventMessage.event;
				if ((tEventPtr->what == keyDown) || (tEventPtr->what == autoKey))
				{    // charCodeMask,keyCodeMask;
					char theChar = tEventPtr->message & charCodeMask;

					switch (theChar)
					{
					case	'c':
					case	'C':
						gColorFlag = !gColorFlag;
						status = noErr;
						break;
					case	'f':
					case	'F':
						gFlashFlag = !gFlashFlag;
						status = noErr;
						break;
					default:
						status = unimpErr;
						break;
					}
				}
				else
					status = unimpErr;
			}
            */
			break;

		default:
			status = unimpErr;
			break;
	}
	return status;	
}

/*
	RegisterVisualPlugin
*/
static OSStatus RegisterVisualPlugin(PluginMessageInfo *messageInfo)
{
	OSStatus			status;
	PlayerMessageInfo	playerMessageInfo;
	Str255				pluginName = kTVisualPluginName;
		
	MemClear(&playerMessageInfo.u.registerVisualPluginMessage,sizeof(playerMessageInfo.u.registerVisualPluginMessage));
	
	BlockMoveData((Ptr)&pluginName[0],(Ptr)&playerMessageInfo.u.registerVisualPluginMessage.name[0],pluginName[0] + 1);

	SetNumVersion(&playerMessageInfo.u.registerVisualPluginMessage.pluginVersion,kTVisualPluginMajorVersion,kTVisualPluginMinorVersion,kTVisualPluginReleaseStage,kTVisualPluginNonFinalRelease);

	playerMessageInfo.u.registerVisualPluginMessage.options					= kVisualWantsIdleMessages | kVisualWantsConfigure;
	playerMessageInfo.u.registerVisualPluginMessage.handler					= (VisualPluginProcPtr)VisualPluginHandler;
	playerMessageInfo.u.registerVisualPluginMessage.registerRefCon			= 0;
	playerMessageInfo.u.registerVisualPluginMessage.creator					= kTVisualPluginCreator;
	
	playerMessageInfo.u.registerVisualPluginMessage.timeBetweenDataInMS		= 0xFFFFFFFF; // 16 milliseconds = 1 Tick,0xFFFFFFFF = Often as possible.
	playerMessageInfo.u.registerVisualPluginMessage.numWaveformChannels		= 2;
	playerMessageInfo.u.registerVisualPluginMessage.numSpectrumChannels		= 2;
	
	playerMessageInfo.u.registerVisualPluginMessage.minWidth				= 64;
	playerMessageInfo.u.registerVisualPluginMessage.minHeight				= 64;
	playerMessageInfo.u.registerVisualPluginMessage.maxWidth				= 32767;
	playerMessageInfo.u.registerVisualPluginMessage.maxHeight				= 32767;
	playerMessageInfo.u.registerVisualPluginMessage.minFullScreenBitDepth	= 0;
	playerMessageInfo.u.registerVisualPluginMessage.maxFullScreenBitDepth	= 0;
	playerMessageInfo.u.registerVisualPluginMessage.windowAlignmentInBytes	= 0;
	
	status = PlayerRegisterVisualPlugin(messageInfo->u.initMessage.appCookie,messageInfo->u.initMessage.appProc,&playerMessageInfo);
		
	return status;
	
}

/**\
|**|	main entrypoint
\**/

OSStatus iTunesPluginMainMachO(OSType message,PluginMessageInfo *messageInfo,void *refCon)
{
	OSStatus		status;
	
	(void) refCon;
	
	switch (message)
	{
		case kPluginInitMessage:
			status = RegisterVisualPlugin(messageInfo);
			break;
			
		case kPluginCleanupMessage:
			status = noErr;
			break;
			
		default:
			status = unimpErr;
			break;
	}
	
	return status;
}
