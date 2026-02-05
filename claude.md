# ZDoom Grappling Hook Mods - Project Overview

This workspace contains mods for ZDoom/GZDoom. Each folder except the '!docs' folder is a separate mod.

## Technical Notes
- All mods use ZScript (version 4.10.0)
- Packaged as PK3 files (ZIP format), using the build_mods.bat that automates building all the above mods. (User will manually use build_mods.bat, don't use it yourself)
- See '!docs/hud text in zscript.md' document for how to implement hud messages correctly if the user asks to use it for a mod project.
- When implementing something, prefer simpler and more reliable methods.
- zdoom wiki and zdoom forums seems to have some form of anti-AI protection because their administration hates AI, as poor their judgement may be, sadly. Anyway, if you need to look up info and you're not sure how to implement it, do a web search of things you can access, google searches or otherwise find out what components are needed, and/or tell the user to go fetch the documentation manually from zdoom's zscript wiki, giving hints what to find, letting the user copy paste the needed info and having them save it to the '!docs' folder.
- Assume mods are used with free mouse look, player able to look up and down.