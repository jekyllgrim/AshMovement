# Modern Movement for ZScript
aka AshMovement is an attempt to add a new ZScript-based movement system to ZDoom. The aim was to make it feel more "modern" without imitating any specific game.

This is not a gameplay mod (although it can be used as such) but rather a resource for custom projects.

**LICENSED UNDER GPLv3** Can be used by anyone for any purpose as long as the use [complies with the license](https://www.gnu.org/licenses/gpl-3.0.html).

Compatible with [UZDoom](https://github.com/UZDoom/UZDoom/releases)

## Features
### Movement
Overall, the movement aims to be much snappier and controllable, allowing much better platforming.
* Player reaches intended movement velocity very quickly instead of a slow ramp-up
* When there's no movement input, player's velocity is reduced very quickly (no slippery movement)
* No straferunning
* Holding the Jump button doesn't let you jump continuously, but there's no forced delay between jumps (you can jump again as soon as you touch the ground)
* Gravity is slightly reduced when performing a jump
* Reworked aircontrol that lets you brake mid-air more easily, while still not allowing to easily change direction
* Jumping while crouching is disabled rather than forcing an uncrouch; crouching during jumping is possible
* Built-in coyote time (for a short time, after crossing a ledge and already mid-air, you can still jump off the air)
* Crouching underwater is impossible, but the crouch button will let you swim down (same with flying)

### View and weapon bobbing
* Reworked view bobbing system based on velocity
* Slight vertical and very slight yaw bobbing pattern (adjustable via properties)
* Weapon bobbing calculated alongside view bobbing, keeping them in sync (however, weapon bobbing ignores the weapon-specific `Weapon.Bob*` properties)
* Weapon dynamically reacts to rotating and pitching camera, as well as to approaching a wall/obstacle
* Dynamic camera reaction when jumping and landing

### Other
* Default view height set to 49 (more reasonable eye level)
* Attack height is always forcefully synced with view height (shots aim directly at crosshair; designed to be compatible with freelook)
* New footstep-sound-playing system that is synced with camera movement (footstep sounds played at the lowest bobbing camera position; SNDINFO included, sounds are not)
* New `*landliquid` player sound to be played when landing on TERRAIN-defined water or into 3D-floor water (SNDINFO and TERRAIN included, sounds are not)

The following properties are exposed in the AM_PlayerPawn class for easy adjustment:
* AM_PlayerPawn.MaxCoyoteTime (default: 10) - duration of coyote time in tics
* AM_PlayerPawn.MaxBobFrequency (default: 30.0) - maximum frequency of view and weapon bobbing achievable when running at maximum possible speed. The actual frequency is scaled to this value based on velocity.
* AM_PlayerPawn.MaxViewBobRage (default: 5.0) - maximum vertical range of view bobbing, i.e. how far the camera can dip down when moving (does not affect weapon bobbing)
* AM_PlayerPawn.ViewBobAngleFactor (default: 0.3) - affects angular (side-to-side) view bobbing. This is a multiplier from MaxViewRange, not an absolute value.
* AM_PlayerPawn.LandingViewDipDistance (default: 10.0) - how far the camera can move downward when landing
* AM_PlayerPawn.VerticalWeaponBobRange (default: 2.3) - how far the weapon can move up-down when bobbing
* AM_PlayerPawn.HorizontalWeaponBobRange (default: 7.0) - how far the weapon can move left/right when bobbing

## How to use
### For testing purposes
* [Download the repository](https://github.com/jekyllgrim/AshMovement/archive/refs/heads/main.zip)
* Run the downloaded file as a mod in Doom (it'll replace the existing player class)
### In your project
* [Download the repository](https://github.com/jekyllgrim/AshMovement/archive/refs/heads/main.zip)
* Copy the AshScript folder into your project and `#include` the files in it via your core `zscript` file
* Modify the AM_PlayerPawn class as desired. Alternatively, create a new class based on it.
  * If you don't want any DoomPlayer features, change AM_PlayerPawn's parent class from DoomPlayer to PlayerPawn (or to another desired class, like one from Heretic or Hexen)
* Copy TERRAIN and SNDINFO definitions and then add sounds for them (sounds are NOT included with this resource)
* If you plan to release your project anywhere, it'll have to be under GPLv3 to comply
