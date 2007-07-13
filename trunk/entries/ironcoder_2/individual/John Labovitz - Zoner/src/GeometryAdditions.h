// after http://cocoadev.com/index.pl?NSRectToCGRect

static inline CGRect NSRectToCGRect(NSRect nsRect) {
	
    return *(CGRect*)&nsRect;
}


static inline NSRect CGRectToNSRect(CGRect cgRect) {
	
    return *(NSRect*)&cgRect;
}


static inline CGPoint NSPointToCGPoint(NSPoint nsPoint) {
	
    return *(CGPoint*)&nsPoint;
}


static inline NSPoint CGPointToNSPoint(CGPoint cgPoint) {
	
    return *(NSPoint*)&cgPoint;
}