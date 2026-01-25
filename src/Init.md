### <a id="init-fb2f"></a>Init ($FB2F)

**Description:**

This routine initializes the system by clearing the [STATUS](#status) zero-page location (often used for debugging). It then proceeds to read the `LORES ($C056)` soft switch and the `TXTPAGE1 ($C054)` soft switch, preparing for video mode configuration. Control then implicitly transfers to the [SetTxt](#settxt-fb39) routine, which handles further text screen initialization, including setting the text mode and defining the full-screen window.

**Input:**

*   **Registers:** N/A
*   **Memory:**
    *   `LORES ($C056)`: Read-only soft switch that determines if the system is in low-resolution graphics mode.
    *   `TXTPAGE1 ($C054)`: Read-only soft switch that controls the activation of text page 1.

**Output:**

*   **Registers:**
    *   A: Contains the low byte of the calculated base address for the text line ([BASL](#basl)).
    *   X: Undefined.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   [STATUS](#status) (address $48): Set to $00.
    *   Memory locations modified by [SetTxt](#settxt-fb39) (e.g., [WNDTOP](#wndtop), [WNDBTM](#wndbtm), [WNDWDTH](#wndwdth), [BASL/BASH](#basl-bash)).
    *   Display settings are configured for text Page 1 and full-screen text window mode (through `SetTxt`).

**Side Effects:**

*   Clears the [STATUS](#status) zero-page location.
*   Reads the `LORES` and `TXTPAGE1` soft switches.
*   Implicitly transfers control to [SetTxt](#settxt-fb39) for text screen initialization.
*   Configures the screen for full window display and text Page 1 (via `SetTxt`).

**See also:**

*   [SetTxt](#settxt-fb39)
*   [STATUS](#status)
*   `LORES` (soft switch)
*   `TXTPAGE1` (soft switch)