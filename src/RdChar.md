### <a id="rdchar-fd35"></a>RdChar ($FD35)

**Description:**

This routine activates escape mode and then jumps to the [RdKey](#rdkey-fd0c) routine to read a character from the keyboard.

*   **Memory:**
    *   [CH](#ch) (address $24): Horizontal position of the cursor.
    *   [BASL/BASH](#basl-bash) (address $28-$29): Base address of the current line.
**Output:**

*   **Registers:**
    *   A: Contains the ASCII code of the key pressed.
    *   X: Preserved
    *   Y: Undefined
    *   P: Flags affected.
*   **Memory:** None.

**Side Effects:**

*   Activates escape mode.
*   Transfers control to [RdKey](#rdkey-fd0c).

**See also:**

*   [RdKey](#rdkey-fd0c)
*   [KeyIn](#keyin-fd1b)
*   [Escape Sequences with RdChar](#escape-sequences-with-rdchar)