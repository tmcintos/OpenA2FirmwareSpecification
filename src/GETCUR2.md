### <a id="getcur2-ccad"></a>GETCUR2 ($CCAD) (Internal)

**Description:**

This is an **internal helper routine** called by [CLRCH](#clrch-fee9) (and potentially other routines) to update the current horizontal cursor positions stored in zero-page locations [CH](#ch), [OLDCH](#oldch), and [OURCH](#ourch). It takes the desired horizontal cursor value in the Y register. If the system is in 80-column video mode (checked via the `RD80VID` soft switch), it pegs [CH](#ch) and [OLDCH](#oldch) to $00, effectively resetting the cursor to the far left, while [OURCH](#ourch) is always updated with the Y register's value.

**Input:**

*   **Registers:**
    *   Y: The desired horizontal cursor position to apply to [OURCH](#ourch), and potentially [CH](#ch) and [OLDCH](#oldch).
    *   A: N/A
    *   X: N/A
*   **Memory:**
    *   `RD80VID ($C01F)`: A read-only soft switch that determines if the system is currently in 80-column video mode. This value is used to conditionally set [CH](#ch) and [OLDCH](#oldch).

**Output:**

*   **Registers:**
    *   A: Contains the value of [OURCH](#ourch) on exit.
    *   X: Preserved.
    *   Y: Preserved.
    *   P: Flags affected by `bit`, `sty`, and `lda` operations.
*   **Memory:**
    *   [OURCH](#ourch) (address $057B): Always updated with the value of the Y register from entry.
    *   [CH](#ch) (address $24): Set to $00 if in 80-column mode, otherwise set to the value of the Y register from entry.
    *   [OLDCH](#oldch) (address $047B): Set to $00 if in 80-column mode, otherwise set to the value of the Y register from entry.

**Side Effects:**

*   Reads the `RD80VID` soft switch.
*   Updates zero-page locations [OURCH](#ourch), [CH](#ch), and [OLDCH](#oldch) based on the input Y register and the current video mode.

**See also:**

*   [CLRCH](#clrch-fee9)
*   [HOMECUR](#homecur-cda5)
*   [CH](#ch)
*   [OLDCH](#oldch)
*   [OURCH](#ourch)
*   `RD80VID` (soft switch)