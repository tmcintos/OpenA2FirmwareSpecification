### <a id="scroll-fc70"></a>Scroll ($FC70)

**Description:**

This routine scrolls the text window up by one line, moving all characters upwards. The cursor's absolute position remains unchanged. It calls [BasCalc](#bascalc-fbc1) to update [BASL/BASH](#basl-bash) for the new line.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [WNDTOP](#wndtop) (address $22): Upper boundary of the text window.
    *   [WNDBTM](#wndbtm) (address $23): Lower boundary of the text window.
    *   [CH](#ch) (address $24): Horizontal position of the cursor.
    *   [CV](#cv) (address $25): Vertical position of the cursor.
    *   [BASL/BASH](#basl-bash) (address $28-$29): Base address of the current line.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Undefined
    *   P: Undefined
*   **Memory:**
    *   Text memory within the active window is scrolled upwards.

**Side Effects:**

*   Scrolls the displayed text.
*   Updates [BASL/BASH](#basl-bash).

**See also:**

*   [BasCalc](#bascalc-fbc1)
*   [WNDTOP](#wndtop)
*   [WNDBTM](#wndbtm)
*   [CH](#ch)
*   [CV](#cv)
*   [BASL/BASH](#basl-bash)