### <a id="homecur-cda5"></a>HOMECUR ($CDA5) (Internal)

**Description:**

This is an **internal helper routine** used by [Home](#home-fc58) to move the cursor to the upper-left corner of the current text window. It achieves this by calling [CLRCH](#clrch-fee9) to set the horizontal cursor indices, then setting the vertical cursor to the top of the window as defined by [WNDTOP](#wndtop), and finally jumping to [NEWVTABZ](#newvtabz-fc88) to set the screen base address and update the vertical cursor's zero-page location ([OURCV](#ourcv)).

**Input:**

*   **Registers:** N/A
*   **Memory:**
    *   [WNDTOP](#wndtop) (address $22): The top edge of the text window. Its value is read to set the vertical cursor position.

**Output:**

*   **Registers:**
    *   A: Modified by internal operations.
    *   X: Modified by internal operations.
    *   Y: Modified by internal operations (due to calls to [CLRCH](#clrch-fee9)).
    *   P: Flags affected by internal operations.
*   **Memory:**
    *   [CH](#ch) (address $24): Set to $00 by [CLRCH](#clrch-fee9) (if in 80-column mode) or a value derived from the input Y register.
    *   [OLDCH](#oldch) (address $047B): Set by [CLRCH](#clrch-fee9).
    *   [OURCH](#ourch) (address $057B): Set by [CLRCH](#clrch-fee9).
    *   [CV](#cv) (address $25): Set to the value of [WNDTOP](#wndtop).
    *   [OURCV](#ourcv) (address $05FB): Updated by [NEWVTABZ](#newvtabz-fc88).
    *   [BASL/BASH](#basl-bash) (address $28-$29): Updated by [NEWVTABZ](#newvtabz-fc88).
    *   Screen memory: Potentially affected by subroutines that draw the cursor.

**Side Effects:**

*   Calls [CLRCH](#clrch-fee9) to handle horizontal cursor positioning.
*   Sets [CV](#cv) to the value of [WNDTOP](#wndtop).
*   Transfers control to [NEWVTABZ](#newvtabz-fc88).
*   Accesses [WNDTOP](#wndtop).

**See also:**

*   [Home](#home-fc58)
*   [CLRCH](#clrch-fee9)
*   [NEWVTABZ](#newvtabz-fc88)
*   [WNDTOP](#wndtop)
*   [CV](#cv)
*   [OURCV](#ourcv)