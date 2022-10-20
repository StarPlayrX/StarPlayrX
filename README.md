# StarPlayrX

### Note this has not been tested with macOS Ventura 13.0. You may be an issue logging in.

#### This current open source version is considered beta, many changes were made to its middleware and client software and has not been released to the AppStore. Once we are happy with it, there will be a macOS Catalyst release on StarPlayrX.com and a new iOS AppStore release.

Sirius XM streaming radio for iOS, macOS and iPadOS. StarPlayrX is accessible and this is one of its strong suits.

X stands for ten. Back in 2009 StarPlayr was once on macOS, iOS, Windows and Windows Mobile. It was run by a team of 4 faithful engineers including myself. The startup was called NiceMac. A decade later, I decided to bring StarPlayrX to the app store. This time under my own name and 100% of it is open sourced.

The Mac Catalyst version of StarPlayrX can be compiled by individuals. There will be macOS future releases, planned for this Fall.

StarPlayrX is open source along with its two libraries StarPlayrRadioKit and SwifterLite. Anyone who is interested and has some experience with Swift can create their own StarPlayr.

<img src="https://user-images.githubusercontent.com/52664524/192068375-da29200b-00c5-42d2-951c-89acb12caaf6.png" width="262"> <img src="https://user-images.githubusercontent.com/52664524/192068208-91b5c67e-38b8-438b-8fdc-6ad9b64d0df8.png" width="262"> <img src="https://user-images.githubusercontent.com/52664524/192068072-c8c34cc7-27eb-4850-b26a-aaaeda0e103c.png" width="262">

CameoKit and Perfect4 is now deprecated. It has been replaced with StarPlayrRadioKit and SwifterLite (fork from Swifter). All three repos are located on my Github's main page.
 
CameoKit was StarPlayrX's original abstraction layer between SiriusXM and StarPlayrX. StarPlayrRadioKit is its replacement.

Perfect4 was a super fast Swift server with a good bit of its code in C. Unfortunately Perfect was proving difficult to maintain since its original authors seemed to have abandoned it completely. It was also quite large and needed to have access to its C headers. This has been replaced with SwifterLite, an unofficial fork of Swifter. Swifter was pretty small, but it wasn't fast enough or stable enough to replace Perfect. SwifterLite was born removing 50% of Swifter's original code base and refactored what was remaining. SwifterLite's modifications were designed for Audio and Video streaming for StarPlayrX and future IPTVee projects by Todd Bruss. Anyone can use SwifterLite as a reliable and fast embedded http web server on iOS, macOS and tvOS.

SwifterLite is copyrighted (c) 2016 by the Swifter's individual contributors and (c) 2022 by Todd Bruss 

StarplayrX and StarPlayrRadioKit is copyrighted (c) 2022 by Todd Bruss and NiceMac LLC

StarPlayrX is not affiliated with SiriusXM. StarPlayr trademark is owned by NiceMac LLC. Source Code and Binaries are copyrighted (c) Todd Bruss, NiceMac LLC, StarPlayrX.com

MIT License

"Don't be a Slacker, be a Star Player."
