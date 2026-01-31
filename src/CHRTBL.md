### <a id="chrtbl-ffcc"></a>CHRTBL ($FFCC)

**Description:**

This is the Monitor’s command-character table. The Monitor command parser scans this table to find the index of a typed command character, then uses the same index to select the corresponding dispatch entry from [SUBTBL](#subtbl-ffe3).

**Format:**

- One byte per command.
- In common implementations, entries use “keyboard style” character codes (ASCII with bit 7 set) so they can be compared directly against characters returned by the keyboard input routine.

**Compatibility note:**

Monitor implementations differ across hardware families and firmware revisions. Some IIc-family implementations effectively start the command table at `$FFCD` due to an extra byte at `$FFCC`. For maximum compatibility with historical tooling, a unified firmware should prefer placing the command table at `$FFCC`.

**See also:**

- [SUBTBL](#subtbl-ffe3)
- [TOSUB](#tosub-ffbe)
- [MonZ](#monz-ff69)
