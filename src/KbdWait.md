### <a id="kbdwait-fb88"></a>KbdWait ($FB88)

**Description:**

This routine pauses execution until a key is pressed. If the key is not Control-C, the keyboard strobe is cleared, and the character is passed to [VidOut](#vidout-fbfd). If Control-C is detected, clearing is bypassed, and control transfers directly to [VidOut](#vidout-fbfd).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Contains the ASCII code of the key pressed.
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags affected by internal operations.
*   **Memory:**
    *   The keyboard strobe is cleared if the key pressed is not Control-C.

**Side Effects:**

*   Pauses program execution until a key is pressed.
*   Conditionally clears the keyboard strobe.
*   Transfers control to [VidOut](#vidout-fbfd).

**See also:**

*   [VidOut](#vidout-fbfd)
*   [COUT](#cout-fded)
*   [KeyIn](#keyin-fd1b)