### <a id="storadv-fbf0"></a>StorAdv ($FBF0)

**Description:**

This routine places a printable character (from the A register) on the text screen at the line determined by [BASL/BASH](#basl-bash) and horizontal position by [CH](#ch). After printing, `StorAdv` increments [CH](#ch). If [CH](#ch) + 1 exceeds [WNDWDTH](#wndwdth), it executes a carriage return.

**Input:**

*   **Registers:**
    *   A: The printable ASCII character to be displayed on the screen.
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CH](#ch) (address $24): Horizontal position of cursor.
    *   [BASL/BASH](#basl-bash) (address $28-$29): Base address of current line.
    *   [WNDWDTH](#wndwdth) (address $21): Width of the current text window.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Undefined
    *   P: Undefined
*   **Memory:**
    *   Text memory at ([BASL/BASH](#basl-bash) + [CH](#ch)) is modified.
    *   [CH](#ch): The horizontal cursor position is incremented.

**Side Effects:**

*   Displays a character.
*   Advances the horizontal cursor position.
*   May trigger a carriage return.

**See also:**

*   [Advance](#advance-fbf4)
*   [COUT](#cout-fded)
*   [BASL/BASH](#basl-bash)
*   [CH](#ch)
*   [WNDWDTH](#wndwdth)
*   [CV](#cv)