### <a id="settxt-fb39"></a>SetTxt ($FB39)

**Description:**

This routine configures the display for a full text window. It reads the current video mode soft switches to determine the display configuration, then sets window parameters and configures the display for full-screen text mode.

**Hardware Details:**
During execution, SetTxt reads the following hardware soft switches (memory-mapped I/O locations):
- `TXTSET` ($C051): Reads to set text mode (any read action enables text mode)
- `TXTCLR` ($C050): Reads to clear text mode for graphics (any read action disables text mode)
- `MIXSET` ($C053): Reads to enable mixed graphics/text display
- Window width is determined via the [WNDREST](#wndrest) internal call, which detects 40/80 column mode

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:** N/A.

**Output:**

*   **Registers:**
    *   A: Contains the low byte of the calculated base address for the text line ([BASL](#basl-bash)).
    *   X: Preserved.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   [BASL/BASH](#basl-bash): Updated with the base memory address for the last line of text.
    *   Display mode is set to full-screen text window.

**Side Effects:**

*   Configures the screen for a full text window.
*   Updates [BASL/BASH](#basl-bash) by calculating the base address for the text line.

**See also:**

*   [Init ($FB2F)](#init-fb2f)
*   [BasCalc ($FBC1)](#bascalc-fbc1)
*   [BASL/BASH](#basl-bash)
