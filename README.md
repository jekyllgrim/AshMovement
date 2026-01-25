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
* Weapon bobbing calculated alongside view bobbing, keeping them in sync. It also respects `Weapon.BobRangeX` and `Weapon.BobRangeY` properties (they're added on top of player-specifid bob properties), but ignores `Weapon.BobStyle` and `Weapon.BobSpeed` (movement style is generalized, and speed is tied to view bobbing)
* Weapon dynamically reacts to rotating and pitching camera, as well as to approaching a wall/obstacle
* Dynamic camera reaction when jumping and landing

### Other

* Default view height set to 49 (more reasonable eye level)
* Attack height is always forcefully synced with view height (shots aim directly at crosshair; designed to be compatible with freelook)
* New footstep-sound-playing system that is synced with camera movement (footstep sounds played at the lowest bobbing camera position; SNDINFO included, sounds are not)
* New `*landliquid` player sound to be played when landing on TERRAIN-defined water or into 3D-floor water (SNDINFO and TERRAIN included, sounds are not)

The following properties are exposed in the AM_PlayerPawn class for easy adjustment:

| Property name               | Default value | Description                                                                                                                                                                                                                                                                     |
| --------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AM_PlayerPawn.MaxCoyoteTime | 10            | Duration of coyote time in tics                                                                                                                                                                                                                                                 |
| MaxBobFrequency             | 30.0          | Maximum frequency of view   bobbing achieved at maximum running velocity (scales with actual velocity)                                                                                                                                                                          |
| LandingViewDipDistance      | 5.0           | Maximum vertical downward   distance the camera can travel upon landing                                                                                                                                                                                                         |
| VerticalViewBobRange        | 2.3           | Maximum distance of vertical   camera bobbing when moving                                                                                                                                                                                                                       |
| HorizontalViewBobRange      | 0.3           | Maximum horizontal yaw (angle)   of camera rotation when moving                                                                                                                                                                                                                 |
| HorizontalWeaponBobRange    | 7.0           | Maximum horizontal range of   weapon bob (multiplied by weapon-specific Weapon.BobRangeX)                                                                                                                                                                                       |
| VerticalWeaponBobRange      | 2.3           | Maximum vertical range of weapon   bob (multiplied by weapon-specific Weapon.BobRangeY)                                                                                                                                                                                         |
| WeaponLeanPitchRangeMin     | 0.0           | How far the weapon can be pushed   UP by when moving the camera DOWN (has to be <= 0.0; negative means   higher). This is zero by default to avoid potential sprite cutoffs. If   there's enough sprite space below the screen or you're using 3D models, make   this NEGATIVE. |
| WeaponLeanPitchRangeMax     | 14.0          | How far the weapon can be pushed   DOWN by when moving the camera UP (has to be >= 0.0; positive = lower).                                                                                                                                                                      |
| WeaponLeanYawRange          | 14.0          | How far the weapon can be pushed   left/right by turning the camera right/left.                                                                                                                                                                                                 |
| WeaponLeanDistRange         | 34.0          | How far the weapon can be pushed   down by approaching an obstacle (negative = further down).                                                                                                                                                                                   |
| Weapon3DLeanPitchRangeMin   | -6.0          | 3D weapons only: How far the   weapon can be pushed UP by when moving the camera DOWN (has to be <= 0.0;   negative means higher).                                                                                                                                              |
| Weapon3DLeanPitchRangeMax   | 6.0           | 3D weapons only: How far the   weapon can be pushed DOWN by when moving the camera UP (has to be >= 0.0;   positive = lower).                                                                                                                                                   |
| Weapon3DLeanYawRange        | 9.0           | 3D weapons only: How far the   weapon can be pushed left/right by turning the camera right/left.                                                                                                                                                                                |
| Weapon3DLeanDistRange       | 34.0          | 3D weapons only: How far the   weapon can be pushed down by approaching an obstacle (negative = further   down).                                                                                                                                                                |

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
