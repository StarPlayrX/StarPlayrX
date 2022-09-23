# StarPlayrX
Sirius XM streaming radio for iOS, macOS and iPadOS. StarPlayrX is accessible and this is one of its strong suits.

X stands for ten. StarPlayr was originally targeted for iOS back in 2009. The app encountered some misfortune and NiceMac was disbanned. A decade later its original creator and original founding member of NiceMac, Todd Bruss created StarPlayrX from scratch and released it to the iOS app store. 

The Mac Catalyst version of StarPlayrX can be compiled by individuals. There will be macOS future releases, planned for this Fall.

StarPlayrX is open source along with its two libraries StarPlayrRadioKit and SwifterLite, so who is interested and have some experience with Swift can create their own StarPlayr.

<img src="https://user-images.githubusercontent.com/52664524/192068008-80ab88bd-d4a4-441b-a99e-656ab4c7dc77.png" width="400"><img src="https://user-images.githubusercontent.com/52664524/192068072-c8c34cc7-27eb-4850-b26a-aaaeda0e103c.png" width="400">

CameoKit and Perfect4 is now deprecated. It has been replaced with StarPlayrRadioKit and SwifterLite (fork from Swifter). All three repos are located on my Github's main page.
 
CameoKit was StarPlayrX's original abstraction layer between SiriusXM and StarPlayrX. StarPlayrRadioKit is its replacement.

Perfect4 was a super fast Swift server with a good bit of its code in C. Unfortunately Perfect was proving difficult to maintain since its original authors seemed to have abandoned it completely. It was also quite large and needed to have access to its C headers. This has been replaced with SwifterLite, an unofficial fork of Swifter. Swifter was pretty small, but it wasn't fast enough or stable enough to replace Perfect. SwifterLite was born removing 50% of Swifter's original code base and refactored what was remaining. SwifterLite is made specfically for StarPlayrX and future IPTVee projects by Todd Bruss, but anyone can use SwifterLite as a reliable and fast embedded http web server on iOS, macOS and tvOS.

SwifterLite is copyrighted (c) 2016 by the Swifter's individual contributors and (c) 2022 by Todd Bruss 

StarplayrX and StarPlayrRadioKit is copyrighted (c) 2022 by Todd Bruss and NiceMac LLC

StarPlayrX is not affiliated with SiriusXM. StarPlayr trademark is owned by NiceMac LLC. Source and Binaries are copyrighted (c) Todd Bruss, NiceMac LLC, StarPlayrX.com

"Don't be a Slacker, be a Star Player."
