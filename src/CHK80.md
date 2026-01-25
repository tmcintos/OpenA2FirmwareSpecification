### <a id="chk80-cdcd"></a>CHK80 ($CDCD) (Internal)

**Description:**

This is an **internal helper routine** called during input/output setup (e.g., as part of the `DOPR0` routine). Its purpose is to check if the system is currently in 80-column video mode and, if so, to convert the display to 40-column mode. If the system is already in 40-column mode, it simply proceeds without modification.

The routine first checks the `RD80VID ($C01F)` soft switch. If it indicates 40-column mode, it branches to [SETX](#setx-ce1a). If in 80-column mode, it then proceeds to configure a 40-column text window, potentially manipulating [WNDTOP](#wndtop) and [WNDWDTH](#wndwdth) based on `RDTEXT` soft switch.

**Input:**

*   **Registers:** N/A (all register inputs are internal or passed to subroutines).
*   **Memory:**
    *   `RD80VID ($C01F)`: Read-only soft switch that determines if the system is currently in 80-column video mode.
    *   `RDTEXT ($C01A)`: Read-only soft switch that indicates if the system is in text mode or graphics mode, used by [WIN0](#win0-cdd5).

**Output:**

*   **Registers:**
    *   A: Modified by various operations.
    *   X: Modified by various operations.
    *   Y: Modified by various operations.
    *   P: Flags affected by bitwise and conditional operations.
*   **Memory:**
    *   [WNDTOP](#wndtop) (address $22): May be written to by [WIN0](#win0-cdd5).
    *   [WNDWDTH](#wndwdth) (address $21): May be written to by [WIN0](#win0-cdd5).
    *   `CLR80COL ($C000)`: Soft switch (written by [WIN0](#win0-cdd5)).
    *   `CLR80VID ($C00C)`: Soft switch (written by [WIN0](#win0-cdd5)).

**Side Effects:**

*   Reads the `RD80VID` soft switch.
*   Conditionally branches to [SETX](#setx-ce1a).
*   If in 80-column mode, it flows into [WIN40](#win40-cdd2), which then calls [WIN0](#win0-cdd5).
*   May write to `CLR80COL` and `CLR80VID` soft switches (via [WIN0](#win0-cdd5)).
*   Modifies zero-page locations [WNDTOP](#wndtop) and [WNDWDTH](#wndwdth).

**See also:**

*   `DOPR0 ($FECE)` (internal routine)
*   `RD80VID` (soft switch)
*   [SETX](#setx-ce1a) (internal routine)
*   [WIN40](#win40-cdd2) (internal routine)
*   [WIN0](#win0-cdd5) (internal routine)
*   [WNDTOP](#wndtop)
*   [WNDWDTH](#wndwdth)
*   `CLR80COL` (soft switch)
*   `CLR80VID` (soft switch)