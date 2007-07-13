Pancake Day by Jonathan Wight

This is my project for the first #macsb Iron Coder competition: (http://ironcoder.org)

How to use:

Drag the little black & red target window over any UI element. Icons work best. Icons in the dock work fine. Icons in the finder should work too.

The floating palette window will contain a preview of whatever content the icon represents. Special previewer classes exist for Image files, PDFs, HTML, and QuickTime files.

Use of APi:
This project uses the Accessibility API to get the URL of the UI element. It also used Spotlight API to get metadata about the item and QTKit/WebKit and PDFKit to create the previews

Use of Theme:
The program is called Pancake Day. I am a strong believer in less is more.

It was going to have a string of beads linking the preview window to the target window but that got tricky and it turned out a few people were doing that.