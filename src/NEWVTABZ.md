### <a id="newvtabz-fc88"></a>NEWVTABZ ($FC88) (Internal)

**Description:**

This is an **internal helper routine** called by routines like [HOMECUR](#homecur-cda5) and [LF](#lf-fc66). Its primary function is to update the zero-page location [OURCV](#ourcv) with the current vertical cursor position from [CV](#cv), and then to branch into the [VTABZ](#vtabz-fc24) routine. [VTABZ](#vtabz-fc24) is responsible for calculating and setting the base address of the current text line ([BASL/BASH](#basl-bash)).

**Input:**

*   **Registers:** N/A
*   **Memory:**
    *   [CV](#cv) (address $25): The current vertical cursor position, which is read and stored in [OURCV](#ourcv).

**Output:**

*   **Registers:**
    *   A: Modified by internal calls (specifically [VTABZ](#vtabz-fc24) and [BASCALC](#bascalc-fbc1)).
    *   X: Modified by internal calls.
    *   Y: Modified by internal calls.
    *   P: Flags affected by internal operations.
*   **Memory:**
    *   [OURCV](#ourcv) (address $05FB): Updated with the value from [CV](#cv).
    *   [BASL/BASH](#basl-bash) (address $28-$29): Updated by [VTABZ](#vtabz-fc24).

**Side Effects:**

*   Updates [OURCV](#ourcv) with the current vertical cursor position.
*   Transfers control to [VTABZ](#vtabz-fc24).

**See also:**

*   [HOMECUR](#homecur-cda5)
*   [LF](#lf-fc66)
*   [VTABZ](#vtabz-fc24)
*   [CV](#cv)
*   [OURCV](#ourcv)
*   [BASL/BASH](#basl-bash)