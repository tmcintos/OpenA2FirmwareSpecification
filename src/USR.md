### USR ($FECA)

**Description:**

Monitor command handler that jumps through the user vector in RAM (the Control-Y/USR entry), allowing system software to install a custom Monitor command handler.

**Input:**

- **Registers:** A/X/Y undefined (not used as inputs).
- **Memory:** User vector in RAM (commonly labeled `USRADR`, typically at $03F8).

**Output:**

- Does not return unless the user handler returns.

**Side Effects:**

- Transfers control to the user-installed handler.

**Notes:**

- This is typically reached via the Monitor’s command dispatcher tables ([CHRTBL](#chrtbl-ffcc)/[SUBTBL](#subtbl-ffe3)).

**See also:**

- [MonZ](#monz-ff69)
- [TOSUB](#tosub-ffbe)
- [SUBTBL](#subtbl-ffe3)
