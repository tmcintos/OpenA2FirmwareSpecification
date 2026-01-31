### BASCONT ($FEB3)

**Description:**

Monitor command handler that transfers control to the system’s BASIC warm-start entry ("continue" / warm start behavior).

**Input:**

- **Registers:** A/X/Y undefined (not used as inputs).
- **Memory:** None.

**Output:**

- Does not return.

**Side Effects:**

- Transfers control into BASIC warm-start logic.

**Notes:**

- This is typically reached via the Monitor’s command dispatcher tables ([CHRTBL](#chrtbl-ffcc)/[SUBTBL](#subtbl-ffe3)).

**See also:**

- [MonZ](#monz-ff69)
- [TOSUB](#tosub-ffbe)
- [SUBTBL](#subtbl-ffe3)
