"""
The Game of Life in screensaver form.

Based on code from:

    http://davidbau.com/archives/2006/07/26/python_curses_life.html
"""
import objc

from Foundation import *
from AppKit import *
from ScreenSaver import *
from random import random, randrange
from PyObjCTools import NibClassBuilder
from pylife import LifeBoard

kModuleName = "com.SuperMegaUltraGroovy.LifeSaver"

NibClassBuilder.extractClasses("LifeSaverConfig")

schemes = {
    'Cool Blues':[ '5c73b8', '405080', 'cfd4e6', '3054bf' ],
    'Desert':[ 'FFE500', 'B3A000', 'FFF9BF', 'FFF280' ],
    'Hot Pink':[ 'CC0099', '8F006B', 'FFBFEF', 'FF80DF' ],
    'Autumn': ['FF6600', 'B34700', 'FFD9BF', 'FFB380']
}

patterns = { 
    'Gosper Glider Gun': 
    {
        'pat':[ ( 0, 3 ), ( 0, 4 ), ( 1, 3 ), ( 1, 4 ), ( 10, 2 ), ( 10, 3 ), ( 10, 4 ),
                ( 11, 1 ), ( 11, 5 ), ( 12, 0 ), ( 12, 6 ), ( 13, 0 ), ( 13, 6 ), ( 14, 3 ), 
                ( 15, 1 ), ( 15, 5 ), ( 16, 2 ), ( 16, 3 ), ( 16, 4 ), ( 17, 3 ), ( 20, 4 ), 
                ( 20, 5 ), ( 20, 6 ), ( 21, 4 ), ( 21, 5 ), ( 21, 6 ), ( 22, 3 ), ( 22, 7 ), 
                ( 24, 2 ), ( 24, 3 ), ( 24, 7 ), ( 24, 8 ), ( 34, 5 ), ( 34, 6 ), ( 35, 5 ), 
                ( 35, 6 ) ],
        'dim':(36,9)
    },
    'Diehard':
    {
        'pat':[(0, 1), (1, 0), (1, 1), (5, 0), (6, 0), (6, 2), (7, 0)],
        'dim':(8, 3)
    },
    'Acorn':
    {
        'pat':[(0, 0), (1, 0), (1, 2), (3, 1), (4, 0), (5, 0), (6, 0)],
        'dim':(7, 3)
    },    
    'Infinite Pattern 1':
    {
        'pat':[ (0, 0), (2, 0), (2, 1), (4, 2), (4, 3), (4, 4), (6, 3), (6, 4), (6, 5), (7, 4) ],
        'dim':(8, 6)
    },
    'Infinite Pattern 2':
    {
        'pat':[ ( 0, 0 ), ( 2, 0 ), ( 4, 0 ), ( 1, 1 ), ( 2, 1 ), ( 4, 1 ), ( 3, 2 ), 
                ( 4, 2 ), ( 0, 3 ), ( 0, 4 ), ( 1, 4 ), ( 2, 4 ), ( 4, 4 ) ],
        'dim':(5,5)
    },
    'Infinite Pattern 3':
    {
        'pat':[ (0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (5, 0), (6, 0), (7, 0),
                (9, 0), (10, 0), (11, 0), (12, 0), (13, 0),
                (17, 0), (18, 0), (19, 0),
                (26, 0), (27, 0), (28, 0), (29, 0), (30, 0), (31, 0), (32, 0),
                (34, 0), (35, 0), (36, 0), (37, 0), (38, 0) ],
        'dim':(39, 1)
    }
}

def NSColorFromWeb( color ):
    r, g, b = float( int( color[0:2], 16 ) / 255.0 ), float( int( color[2:4], 16 ) / 255.0 ), float( int( color[4:6], 16 ) / 255.0 )
    return NSColor.colorWithCalibratedRed_green_blue_alpha_( r, g, b, 1.0 )

class LifeSaver (NibClassBuilder.AutoBaseClass):
    
    def initialize(self):
        defaults = ScreenSaverDefaults.defaultsForModuleWithName_(kModuleName);
        
        defs = { 'Pattern':'Gosper Glider Gun', 'ColorScheme':'Desert' }
        
        defaults.registerDefaults_(defs)
        
    def animateOneFrame(self):
        NSColor.blackColor().set()
        NSRectFill(self.frame())
        
        NSColor.whiteColor().set()
        self.screen.step(1)
    
    def startAnimation(self):
        board = LifeBoard()

        defaults = ScreenSaverDefaults.defaultsForModuleWithName_(kModuleName);
                
        self.screen = LifeScreen(board, self.frame(), (64,64))
        self.screen.setPattern(defaults.stringForKey_(u'Pattern'))
        self.screen.setColorScheme(defaults.stringForKey_(u'ColorScheme'))

        super( LifeSaver, self ).startAnimation()
        
    def hasConfigureSheet(self):
        return True
        
    def awakeFromNib(self):
        "Populate all the controls when the nib is loaded."
        defaults = ScreenSaverDefaults.defaultsForModuleWithName_(kModuleName);
        
        self.colorSchemePopup.removeAllItems()
        for k in schemes.keys():
            self.colorSchemePopup.addItemWithTitle_( k )
            
        self.colorSchemePopup.selectItemWithTitle_( defaults.stringForKey_(u'Pattern') )
            
        self.patternPopup.removeAllItems()
        for k in patterns.keys():
            self.patternPopup.addItemWithTitle_(k)
            
        self.colorSchemePopup.selectItemWithTitle_( defaults.stringForKey_(u'ColorScheme') )
    
    def configureSheet(self):
        print "ConfigSheet before " + str(self.configSheet)
        if not self.configSheet:
            if not NSBundle.loadNibNamed_owner_(u"LifeSaverConfig", self):
                print "Failed to load configuration sheet"
        print "ConfigSheet after " + str(self.configSheet)
        return self.configSheet
        
    #
    # Nib Actions
    #
    def okClick_(self, sender):
        "When OK is clicked in the UI, save the settings in the defaults"
        defaults = ScreenSaverDefaults.defaultsForModuleWithName_(kModuleName);
        
        defaults.setObject_forKey_(str(self.colorSchemePopup.selectedItem().title()), u'ColorScheme')
        defaults.setObject_forKey_(str(self.patternPopup.selectedItem().title()), u'Pattern')

        NSApplication.sharedApplication().endSheet_(self.configSheet)

    def cancelClick_(self, sender):
        "Just dismiss the sheet if the user chooses to cancel"
        NSApplication.sharedApplication().endSheet_(self.configSheet)
        
        
class LifeScreen:
    
    def __init__(self, board, frame, boardSize):
        
        ( self.curx, self.cury ), ( self.width, self.height ) = (0, 0), boardSize
        
        self.frame = frame
        
        #self.screen = screen
        self.board = board
        self.offsety, self.offsetx = -self.height / 2, -self.width / 2
        self.steps = 0
        
        self.patternWidth, self.patternHeight = 0, 0
                                
    def visibleRect(self):
        return (0, 0, self.width, self.height)

    def setPattern(self, pat):
        self.clear()
        d = patterns[pat]
        self.patternWidth, self.patternHeight = d['dim']
        for x, y in d['pat']:
            self.set( x, y, 1 )
            
    def setColorScheme(self, cs):
        self.colorScheme = schemes[cs]
    
    def set( self, x, y, v ):
        self.board.set( ( self.width / 2 ) - ( self.patternWidth / 2 ) + x, ( self.height / 2 ) - ( self.patternHeight / 2 ) + y, v )

    def redraw(self):
        cells = self.board.getAll(self.visibleRect())
        for x, y in cells:
            # Figure out the segment we're in
            (myX, myY), (myW, myH) = self.frame
            
            blockW = myW / self.width
            blockH = myH / self.height
            
            curX = blockW * ( x )
            curY = blockH * ( y )
            
            NSColorFromWeb( self.colorScheme[randrange(0, len(self.colorScheme))] ).set()
            
            # Integral rects, while sharper, do not look as good
            #NSRectFill( NSInsetRect( NSIntegralRect( ( ( curX, curY ), ( blockW, blockH ) ) ), 1, 1 ) )
            
            NSRectFill( NSInsetRect( ( ( curX, curY ), ( blockW, blockH ) ), 1, 1 ) )
        
    def step(self, steps):
        if self.board.root.width() > 2 ** 28: self.collect()
        self.board.step(steps)
        self.steps = self.steps + steps
        self.redraw()

    def bigstep(self):
        if self.steps == 0: self.step(1)
        else: self.step(self.steps)

    def keepcentered(self):
        maxx, maxy = self.curx - self.width / 4, self.cury - self.height / 4
        minx, miny = maxx - self.width / 2, maxy - self.height / 2
        offsetx = min(maxx, max(minx, self.offsetx))
        offsety = min(maxy, max(miny, self.offsety))
        if self.offsetx != offsetx or self.offsety != offsety:
            self.offsetx, self.offsety = offsetx, offsety
            self.redraw()

    def clear(self):
        self.board.clear()
        self.steps = 0
        self.redraw()

    def collect(self):
        self.board.collect()
        self.redraw()
