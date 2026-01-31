### <a id="setkbd-fe89"></a>SetKbd ($FE89)

**Description:**

This routine sets the input links [KSWL/KSWH](#kswl-kswh) to point to the keyboard input routine, [KeyIn](#keyin-fd1b). It effectively redirects all subsequent standard input operations to the keyboard rather than an expansion slot device.

**Hardware Details:**
This routine internally sets [A2L](#a2l-a2h) to $00 and calls [InPort](#inport-fe8b) to configure the input hooks. The effect is to reset standard input to built-in keyboard input.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Preserved
    *   X: Preserved
    *   Y: Preserved
    *   P: Undefined
*   **Memory:**
    *   [KSWL/KSWH](#kswl-kswh): Updated to contain the 16-bit address of the [KeyIn](#keyin-fd1b) routine.

**Side Effects:**

*   Modifies the system's standard input hooks.
*   Redirects subsequent standard input operations to [KeyIn](#keyin-fd1b).

**See also:**

*   [KeyIn](#keyin-fd1b)
*   [InPort](#inport-fe8b)
*   [KSWL/KSWH](#kswl-kswh)