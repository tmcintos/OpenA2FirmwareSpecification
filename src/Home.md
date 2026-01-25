### <a id="home-fc58"></a>Home ($FC58)

**Description:**

This routine effectively moves the text cursor to the upper-left corner of the current text window and then clears the text display from that position to the end of the current page. In the Apple IIc ROM, it achieves this by first calling the internal helper routine [HOMECUR](#homecur-cda5) to position the cursor, and then flowing into the [CLREOP2](#clreop2-fc44) routine to clear the screen.

**Input:**

*   **Registers:** N/A (all register inputs are handled by the called subroutines).
*   **Memory:**
    *   [WNDTOP](#wndtop) (address $22): The top edge of the text window, read by [HOMECUR](#homecur-cda5).
    *   [OURCH](#ourch) (address $057B): Read by [CLRCH](#clrch-fee9), which is called by [HOMECUR](#homecur-cda5).
    *   `RD80VID ($C01F)`: A soft switch read by [GETCUR2](#getcur2-ccad) (called by [CLRCH](#clrch-fee9)) and [VTABZ](#vtabz-fc24) (branched to by [NEWVTABZ](#newvtabz-fc88), called by [HOMECUR](#homecur-cda5)).
    *   [WNDLFT](#wndlft) (address $20): The left edge of the text window, read by [VTABZ](#vtabz-fc24).
    *   [CV](#cv) (address $25): The current vertical cursor position, read by [VTABZ](#vtabz-fc24) and [CLREOP2](#clreop2-fc44).
    *   [WNDBTM](#wndbtm) (address $23): The bottom edge of the text window, read by [CLREOP2](#clreop2-fc44).

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Preserved.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   [CV](#cv) (address $25): Set to the value of [WNDTOP](#wndtop) by [HOMECUR](#homecur-cda5), and further modified by [CLREOP2](#clreop2-fc44).
    *   [CH](#ch) (address $24): Set to $00 (if in 80-column mode) or a value derived from the input Y register to [GETCUR2](#getcur2-ccad).
    *   [OLDCH](#oldch) (address $047B): Set by [GETCUR2](#getcur2-ccad).
    *   [OURCH](#ourch) (address $057B): Set by [GETCUR2](#getcur2-ccad).
    *   [BASL/BASH](#basl-bash) (address $28-$29): Updated by [VTABZ](#vtabz-fc24) and [BASCALC](#bascalc-fbc1).
    *   Screen memory: Text within the active window is cleared from the cursor position to the end of the page.

**Side Effects:**

*   Calls [HOMECUR](#homecur-cda5) to move the cursor to the upper-left of the text window. This involves a chain of internal calls to [CLRCH](#clrch-fee9), [GETCUR2](#getcur2-ccad), and [NEWVTABZ](#newvtabz-fc88), which branches to [VTABZ](#vtabz-fc24), and finally calls [BasCalc](#bascalc-fbc1).
*   Flows into [CLREOP2](#clreop2-fc44) to clear the screen from the new cursor position to the bottom of the window.
*   Accesses the `RD80VID` soft switch.

**See also:**

*   [HOMECUR](#homecur-cda5)
*   [CLREOP2](#clreop2-fc44)
*   [WNDTOP](#wndtop)
*   [WNDLFT](#wndlft)
*   [CV](#cv)
*   [CH](#ch)
*   [OLDCH](#oldch)
*   [OURCH](#ourch)
*   [BASL/BASH](#basl-bash)
*   `RD80VID` (soft switch)