# unm
UnNoob Me (UNM) — Payday 2 mod for keeping noobs out. Based on NGBTO. Requires BLT.

## Some not so ancient history
UNM was started as an attempt to expand NGBTO ('Noobs Go Back To Overkill' mod by FishTaco) so that it works on very hard difficulty. Later an idea to separate Steam friendlist and whitelist (opposed to blacklist) was born and implemented. However, those changes did not receive warm welcome from FishTaco, so I had to work on my own.
UNM had its first working realization in April 2016, forked from NGBTO R41.

## Current situation
Overkill (PD2 devs) announced skill tree changes, so project was stalled as noone actually knew what the changes would be like. Current implementation (UNM v0.0.1) is based on NGBTO R54 by FishTaco and is not yet fully ready for public use, so please don't use it. I mean it: bugs and messy code from initial developer is present and is probably multiplied by bugs of my own origin.

## Features and diffs (vs NGBTO R54)
* works with VH difficulty
* has whitelist for those who you play with but who are not in your friend list
* blacklist now taked priority over friendlist (so your cheater friends will be kicked unless added to whitelist or you can just ban any friend you don't want to play with)
* changed skills lookup format (more brief now)
* dropped all the localization (trying to focus on the code for the time being, will return it later)

## Changelog
All the information about changes will be present in changelog.txt file.

## Future plans
* support for all the difficulties
* lookup improvements
* statistics improvements
* new WL/BL format to store more information
* display reason for black-/whitelisting in game chat

## Authors
* FishTaco — the initial developer, NGBTO author (currently not affiliated with UNM)
* Rez — bugfixes, adjustments, improvements for UNM (not affiliated with NGBTO)

## License
Currently I go with no license as in 'all rights reserved' till I get this to something stable.
Will be released under latest GPL.
