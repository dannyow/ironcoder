//
//  CFilteringCoreImageView.h
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 11/03/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CCoreImageView.h"

/**
 * @class CFilteringCoreImageView
 * @discussion This subclass of CCoreImageView can use an optional Core Image filter (CIFilter) to filter the image it draws to the screen.
 */
@interface CFilteringCoreImageView : CCoreImageView {
	CIFilter *filter;
}

- (CIFilter *)filter;
- (void)setFilter:(CIFilter *)inFilter;

- (CIImage *)filteredImage;

@end
