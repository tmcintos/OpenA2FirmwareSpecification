### <a id="win0-cdd5"></a>WIN0 ($CDD5) (Internal)

**Description:**

This is an **internal helper routine** responsible for setting up the initial text window configuration, typically used during mode changes (e.g., from 80-column to 40-column mode or vice-versa) or when re-initializing video. It is called by routines like [CHK80](#chk80-cdcd).

The routine first clears [WNDTOP](#wndtop) to $00. It then reads the `RDTEXT ($C01A)` soft switch to determine if it should set [WNDTOP](#wndtop) to 20 (for mixed mode). It then checks the `RD80VID ($C01F)` soft switch to see if the system is currently in 80-column mode and proceeds with necessary screen conversions (calling `SCRN84 ($CE53)` for 80-to-40, or `SCRN48 ($CE80)` for 40-to-80). Finally, it calls [GETCUR](#getcur-cc9d), [SETCUR](#setcur-ecfe), and [BASCALC](#bascalc-fbc1) to update cursor positions and base addresses.

**Input:**

*   **Registers:** N/A (inputs are primarily from zero-page locations and soft switches).
*   **Memory:**
    *   `RDTEXT ($C01A)`: Read-only soft switch that indicates if the system is in text mode or graphics mode.
    *   `RD80VID ($C01F)`: Read-only soft switch that determines if the system is currently in 80-column video mode.
    *   [WNDLFT](#wndlft) (address $20): The left edge of the text window, used for cursor positioning calculations.
    *   [CV](#cv) (address $25): The current vertical cursor position, used for base address calculations.

**Output:**

*   **Registers:**
    *   A: Modified by various operations and internal calls.
    *   X: Modified by internal calls.
    *   Y: Modified by internal calls.
    *   P: Flags affected by various operations.
*   **Memory:**
    *   [WNDTOP](#wndtop) (address $22): Set to $00 or $14 (20 decimal), depending on `RDTEXT`.
    *   [WNDWDTH](#wndwdth) (address $21): May be modified by screen conversion routines ([SCRN84](#scrn84-ce53) or [SCRN48](#scrn48-ce80)).
    *   [CH](#ch) (address $24): Updated by [GETCUR](#getcur-cc9d) and [SETCUR](#setcur-ecfe).
    *   [CV](#cv) (address $25): Read and potentially updated by [BASCALC](#bascalc-fbc1) via [SETCUR](#setcur-ecfe).
    *   [BASL/BASH](#basl-bash) (address $28-$29): Updated by [BASCALC](#bascalc-fbc1).
    *   Screen memory: Modified by column conversion routines ([SCRN84](#scrn84-ce53) or [SCRN48](#scrn48-ce80)).
    *   `CLR80COL ($C000)`, `CLR80VID ($C00C)`, `SET80COL ($C001)`, `SET80VID ($C00D)` soft switches: Potentially modified by screen conversion routines.

**Side Effects:**

*   Clears or sets [WNDTOP](#wndtop).
*   Reads `RDTEXT` and `RD80VID` soft switches.
*   Calls screen conversion routines: `SCRN84 ($CE53)` (80-to-40) or `SCRN48 ($CE80)` (40-to-80).
*   Calls [GETCUR](#getcur-cc9d) and [SETCUR](#setcur-ecfe) to update cursor positions.
*   Calls [BASCALC](#bascalc-fbc1) to calculate base screen addresses.
*   Modifies various soft switches related to video mode.

**See also:**

*   [CHK80](#chk80-cdcd)
*   [WNDTOP](#wndtop)
*   [WNDWDTH](#wndwdth)
*   [CH](#ch)
*   [CV](#cv)
*   [BASL/BASH](#basl-bash)
*   `RDTEXT` (soft switch)
*   `RD80VID` (soft switch)
*   `SCRN84 ($CE53)` (internal routine)
*   `SCRN48 ($CE80)` (internal routine)
*   [GETCUR](#getcur-cc9d) (internal routine)
*   [SETCUR](#setcur-ecfe) (internal routine)
*   [BASCALC](#bascalc-fbc1)