//
//  CMyView.h
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/26/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <ToxicMedia/ToxicMedia.h>

@class CCIMacro;

@interface CMyView : CFilteringCoreImageView {
	float ratio;
	CIFilter *compositingFilter;
}

@end
