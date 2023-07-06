# Greenlight
For cards and scripts to be tested before upload


## Guidelines for passcodes

Announced OCG/TCG cards receive a nine-digit prerelease passcode until they are
released as official product, when the official passcode is used. Speed Duel has
[its own policy](https://github.com/ProjectIgnis/CardScripts/wiki/Skill-Documentation#cdb-handling)
with the `30ZYYYXXX` range and Rush Duel has its own policy in the `160ZYYXXX` range.

- `XXX` is the card index within its set
- `Y` or `YY` is the set index, incremented by one for each chronological set of that product type
	- For Structure Decks, `YY` comes from the prefix, e.g. SD38, ST18, SR10
	- For Structure Deck Enhancement Packs, they share `YY` with the Deck and add 50 to `XXX`
	- For Deck Build Packs, `YY` counts up from the previous one
	- For Duelist Packs, `YY` comes the prefix
	- TODO: there is potential overlap with this above scheme, to be eventually reworked
- Main set: `10ZZYYXXX`
	- Series `ZZ`: currently 11
- Side set: `1002YYXXX`
	- All VJMP-JP (V Jump) promos are considered part of set 200
	- All WJMP-JP (Weekly Shounen Jump) promos are considered part of set 203
	- All SJMP-JP (Saikyou Jump) promos are considered part of set 204
- Structure Deck and Starter Deck: `1003YYXXX`
- Deck Build Pack and Duelist Pack: `1004YYXXX`
- Rush Duel sets: `160ZYYXXX`
	- `Z` product type
	- 0: KP Deck Modification Pack "main booster"
	- 2: CP Character Pack "side booster"
	- 3: ST Starter Deck
	- 4: Promos

Unofficial cards fall under numerous ranges due to historical reasons but are
slowly being reworked and reorganized to the `511YYYXXX` range.

Cards with passcodes aliased to a passcode within 10 are treated as alternate
artworks.

### Upcoming sets

Release date | Set | Prefix | Prerelease passcode
--- | --- | --- | ---
27-May-2023 | [Duelist Pack: Duelists of Explosion][DP28]              | DP28-JP    | 100432XXX
10-Jun-2023 | [Animation Chronicle 2023][AC03]                         | AC03-JP    | 100299XXX
24-Jun-2023 | [Structure Deck: Pulse of the King][SD46]                | SD46-JP    | 100346XXX
22-Jul-2023 | [Age of Overlord][AGOV]                                  | AGOV-JP    | 101202XXX
28-Jul-2023 | [Duelist Nexus][DUNE]                                    | DUNE-EN    | 101201XXX
24-Jun-2023 | [Triple Build Pack: Godbreath Wing][RD/TB01]             | RD/TB01-JP | 160208XXX
??-???-???? | [Saikyō Jump Promos][RD/SJMP]                            | RD/SJMP-JP | 160402XXX

[DP28]: https://yugipedia.com/wiki/Duelist_Pack:_Duelists_of_Explosion
[AC03]: https://yugipedia.com/wiki/Animation_Chronicle_2023
[SD46]: https://yugipedia.com/wiki/Structure_Deck:_Pulse_of_the_King
[AGOV]: https://yugipedia.com/wiki/Age_of_Overlord
[DUNE]: https://yugipedia.com/wiki/Duelist_Nexus
[RD/TB01]: https://yugipedia.com/wiki/Triple_Build_Pack:_Godbreath_Wing
[RD/SJMP]: https://yugipedia.com/wiki/Saikyō_Jump_promotional_cards
