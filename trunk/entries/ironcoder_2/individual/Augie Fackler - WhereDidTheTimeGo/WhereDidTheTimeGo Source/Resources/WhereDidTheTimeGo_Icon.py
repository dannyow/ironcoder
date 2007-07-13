#this is the nodebox source for generating that app icon....

iconSize = 128
size(iconSize, iconSize)
fill(0,0.0)
rect(0,0,iconSize,iconSize)
fill(.75,.80)
beginpath()
moveto(0,iconSize/2)
curveto(0,iconSize/4,iconSize/4, iconSize/8,iconSize/2,0)
curveto(iconSize*3/4,iconSize/8,iconSize, iconSize*1/4,iconSize,iconSize/2)
endpath()
rect(0,iconSize/2,iconSize,iconSize/2)

fill(.5,1.0)

font("Herculanum")

text("so soon",iconSize/2-textwidth("so soon")/2,55)

fontsize(70)

text("?",iconSize/2-textwidth("?")/2,iconSize/2+40)

strokewidth(3)
fill(0,0.0)
stroke(.6)
radius=40.0
oval(10, 70, radius, radius)
line(10+radius/2, 70+radius/2,10+radius/2, 70)
line(10+radius/2, 70+radius/2,10+radius/2, 70+radius*3/4)

stroke(.2)
line(10+radius/2-1.5, 70+radius/2,  10+radius/2+1.5, 70+radius/2)


strokewidth(3)
fill(0,0.0)
stroke(.6)
radius=40.0
oval((iconSize-10-radius), 70, radius, radius)
line((iconSize-10-radius)+radius/2, 70+radius/2,(iconSize-10-radius)+radius/2, 70)
line((iconSize-10-radius)+radius/2, 70+radius/2,(iconSize-10-radius)+radius/2-radius*3/8, 70+radius/2)

stroke(.2)
line((iconSize-10-radius)+radius/2-1.5, 70+radius/2,  (iconSize-10-radius)+radius/2+1.5, 70+radius/2)
