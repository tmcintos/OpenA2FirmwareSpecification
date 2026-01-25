### <a id="vidwait-fb78"></a>VidWait ($FB78)

**Description:**

This routine checks the A register for carriage return (`$8D`). If found, it checks for Control-S (`$93`) on the keyboard. If Control-S is pressed, the keyboard strobe is cleared, and control passes to [KbdWait](#kbdwait-fb88) to pause output. Otherwise, if enhanced video is inactive, control passes to [VidOut](#vidout-fbfd) for standard output. If enhanced video is active, it routes to an internal handler. All keyboard input except Control-S is ignored.

**Input:**

*   **Registers:**
    *   A: The character being processed.
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [KSWL/KSWH](#kswl-kswh) (address $36-$37): Address of the keyboard input routine.

**Output:**

*   **Registers:**
    *   A: Preserved
    *   X: Undefined
    *   Y: Undefined
    *   P: Undefined
*   **Memory:**
    *   Keyboard strobe is cleared if Control-S found.
    *   Display output may occur.

**Side Effects:**

*   Checks for Control-S for output pausing.
*   Processes carriage return.
*   Transfers control to [KbdWait](#kbdwait-fb88) or [VidOut](#vidout-fbfd) based on conditions.

**See also:**

*   [KbdWait](#kbdwait-fb88)
*   [VidOut](#vidout-fbfd)
*   [COUT](#cout-fded)
*   [CH](#ch)
*   [CV](#cv)