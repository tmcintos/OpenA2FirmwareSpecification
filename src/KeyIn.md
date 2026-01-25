### <a id="keyin-fd1b"></a>KEYIN ($FD1B)

**Description:**

This routine is the primary keyboard input subroutine. It reads a keypress directly from the Apple keyboard. Before returning, it randomizes the random-number seed stored in [RNDL/RNDH](#rndl-rndh) ($4E/$4F). When a key is pressed, it removes the cursor from the display and returns the ASCII code of the pressed key in the A register.

**Input:**

*   **Registers:**
    *   A: The character currently below the cursor (this value is used internally for restoring the display after cursor removal).
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:** N/A.

**Output:**

*   **Registers:**
    *   A: The ASCII code of the key pressed.
    *   X: Preserved.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   [RNDL/RNDH](#rndl-rndh) (address $4E-$4F): Updated with a new random-number seed.
    *   Screen: Cursor removed from display.

**Side Effects:**

*   Reads a keypress from the keyboard.
*   Randomizes the [RNDL/RNDH](#rndl-rndh) seed.
*   Removes the cursor from the display.

**See also:**

*   [RNDL/RNDH](#rndl-rndh)
*   [RDKEY ($FDC6)](#rdkey-fd0c)
*   [FD10 ($FD10)](#fd10-fd10)