# Unique Jumpstats plugin

Jumping statistics plugin for Goldsrc Engine (Counter-Strike 1.6) originally developed by Borjomi, but heavily modified by me.

### Supported Build
* ReHLDS 3.4.0.X
* Linux 5787 and higher
* Windows 5758 and higher

### AMXMODX Version
* 1.8.0+

### Required modules
* amxmodx
* amxmisc
* cstrike
* engine
* fakemeta
* hamsandwich
* mysql


### This plugin measures jump techniques in Counter-Strike 1.6.
### These techniques are:
* LongJump
* HighJump
* WeirdJump
* WeirdJump after Double Duck
* CountJump
* Double CountJump
* Multi CountJump
* Drop CountJump
* Drop Double CountJump
* Drop Multi CountJump
* BhopJump
* Drop BhopJump
* Standup BhopJump
* Ladder Bhop
* Real Ladder Bhop
* LadderJump
* Up BhopJump
* Up Standup BhopJump
* Up BhopJump in Duck
* BhopJump in Duck
* DuckBhopJump
* Standup CountJump
* Standup Double CountJump
* Standup Multi CountJump
* Drop Standup CountJump
* Drop Standup Double CountJump
* Drop Standup Multi CountJump
* MultiBhopJump

## Features:
### Jump Stats:
* Distance
* Maxspeed and Gain
* Prestrafe
* Strafes
* Sync
* Duck Count

### Strafe Stats:
* Gain speed each strafe
* Sync each strafe
* Loss on each strafe
* Air time on each strafe

### Jump Beam
* First type = simple beam
* Second type = beam with showing strafes

### Sounds:
* Impressive
* Perfect
* Holy Shit
* Wicked Sick
* Godlike
* Domination

### Turning On/Off Abilities:
* Current Speed
* Jump Prestrafe
* Speed after Ducks
* Jump Stats
* Strafe Stats
* Jump messages in chat
* Jump Beam
* Jump Sounds
* MultiBhop Prestrafe
* LJ Prestrafe
* Block Distance
* Edge Distances
* Edge Distances when

### Connecting to mysql
For security reasons, the connection to the database is made directly inside the file. uq_jumpstats_sql.inc
```C#
	new kz_uq_host [] = "";
	new kz_uq_user [] = "";
	new kz_uq_pass [] = "";
	new kz_uq_db [] = "";
```
