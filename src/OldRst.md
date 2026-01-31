### <a id="oldrst-ff59"></a>OldRst ($FF59)

**Description:**

This routine performs a warm restart, typically after a `RESET` or `MON` command. It initializes the text display to normal characters, clears the screen, and sets the input and output hooks. Specifically, it configures [CSWL/CSWH](#cswl-cswh) to point to [COut1](#cout1-fdf0) (the screen display routine) and [KSWL/KSWH](#kswl-kswh) to point to [KeyIn](#keyin-fd1b) (the keyboard input routine). After these setups, it passes control to the Monitor entry point [Mon ($FF65)](#mon-ff65), which then clears the 6502 processor’s decimal mode flag, sounds the speaker, and fully enters the Monitor. This routine does not return to its caller (it transfers control to the Monitor).

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:** N/A.

**Output:**

*   **Registers:** None (does not return to the calling program).
*   **Memory:**
    *   [INVFLG](#invflg) (address $32): Set to $FF (normal display).
    *   [BASL/BASH](#basl-bash) (address $28-$29): Updated with the base address of the last line in the window.
    *   [CSWL/CSWH](#cswl-cswh) (address $36-$37): Set to point to [COut1](#cout1-fdf0).
    *   [KSWL/KSWH](#kswl-kswh) (address $38-$39): Set to point to [KeyIn](#keyin-fd1b).
    *   Text screen: Initialized and cleared.

**Side Effects:**

*   Initializes the text display to normal characters.
*   Initializes the text screen.
*   Sets standard input and output hooks.
*   Clears the 6502 decimal mode flag (via [Mon ($FF65)](#mon-ff65)).
*   Sounds the speaker (via [Mon ($FF65)](#mon-ff65)).
*   Transfers control to the Monitor ([Mon ($FF65)](#mon-ff65)).
*   Does not return to the calling program.

**See also:**

*   [SelNorm ($FE84)](#setnorm-fe84)
*   [Init ($FB2F)](#init-fb2f)
*   [SetVid ($FE93)](#setvid-fe93)
*   [SetKbd ($FE89)](#setkbd-fe89)
*   [Mon ($FF65)](#mon-ff65)
*   [COut1 ($FDF0)](#cout1-fdf0)
*   [KeyIn ($FD1B)](#keyin-fd1b)
*   [INVFLG](#invflg)
*   [BASL/BASH](#basl-bash)
*   [CSWL/CSWH](#cswl-cswh)
*   [KSWL/KSWH](#kswl-kswh)