# Doom Mods by Reactorcore

![collageZmodsbyRC_img](https://github.com/user-attachments/assets/755da603-eba1-4887-9d06-fd94d25aef2c)

A collection of gameplay-enhancing mini mods for GZDoom that add various cool abilities. They work with any other Doom II mod out there.

## Mods Included

### GrappleZ Reel
A persistent grappling hook with smart weight-based pulling. Fire the hook and it continuously pulls you or your target based on weight - light enemies get reeled to you, while you get pulled at heavy enemies. Features a visible chain trail and extensive customization options.

### GrappleZ Yoink
A different pulse-based grappling hook with cooldown. This one is not continuous, but instead fires a pulse that suddenly yanks you towards a wall or yanks enemies to you. Also has the smart weight based enemy pull-or-be-pulled logic. Very configurable too!

This one also has the experimental feature of being able to pull items too, but its a bit iffy since combining Grapple with Item Pull results in awkward gameplay, hence why I made the next two mods separately.

⚠️ **NOTE:** Do not load GrappleZ Reel and GrappleZ Yoink at the same time! They conflict with each other.

### JediPullZ
Force Pull items towards you using smart telekinesis physics. Press a hotkey and as long as the items are within range, they will be thrown at your direction, but can miss. Highly configurable with mod options, as usual.

### TeleGrabZ
An ability to instantly teleport all nearby visible items directly to you. Items within your configured radius and field of view simply appear at your position. Has a visual teleport effect that lets you easily see what items you grabbed.

### MonsterFallDamageZ
Forces all monsters to have fall damage enabled. Monsters will gib if they fall from sufficiently high enough, around 10-20 meters. Doesn't affect the player, so player will remain immune to fall damage, only monsters are affected. Very lightweight mini mod that works with any monster pack mod.

## Installation
1. Download the latest release PK3 files from the [Releases](../../releases) page
2. Use with GZDoom for Doom II. Probably will work with Doom I too, maybe even other IWADs as well, they're technically universal addons.

## Ingame Mod Options

- **GrappleZ Reel**: 11 settings including pull behavior, weight calculation, strength, and limits
- **GrappleZ Yoink**: 10 settings including target filtering, pull strength, and cooldown
- **JediPullZ**: 5 settings including pull strength, radius, range, and HUD scale
- **TeleGrabZ**: 4 settings including radius, field of view, and HUD scale
- **MonsterFallDamageZ**: No configuration needed

These mods work with most gameplay mods and map packs. They require GZDoom with ZScript support (version 4.10.0+).

## Source Code

All source code is included in this repository. Each mod folder contains:
- ZScript files with the core mechanics
- Configuration files (CVARINFO, MENUDEF, KEYCONF, MAPINFO)
- Any custom assets (sounds, graphics)

Use the included `build_mods.bat` script to package them into PK3 files if you want to build from source.

## No License

Feel free to use and modify these mods for your own gameplay!

## Links

Check out my other Doom mods here:

https://itch.io/c/3164246/mods-various

...and check out everything else I do too:

https://linktr.ee/reactorcore

Enjoy!
- Reactorcore
