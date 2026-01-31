### <a id="rdkey-fd0c"></a>RdKey ($FD0C)

**Description:**

This routine loads the A register with the character at the current cursor position and transfers control to the [FD10](#fd10-fd10) routine. [FD10](#fd10-fd10) then indirectly jumps to the configured input routine (e.g., [KeyIn](#keyin-fd1b) or `C3KeyIn`). Effects like updating [RNDL/RNDH](#rndl-rndh) occur via the called input routine.

**Escape sequences:** On systems that support Monitor escape sequences, the escape-enabled path is entered via [RdChar](#rdchar-fd35) (and `GetLnZ` typically uses that path). `RdKey` by itself is the basic “read a key” entry point and does not necessarily implement escape processing unless the caller enters through the escape-enabled path.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CH](#ch) (address $24): Horizontal position of the cursor.
    *   [BASL/BASH](#basl-bash) (address $28-$29): Base address of the current line.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Undefined
    *   Y: Undefined
    *   P: Undefined
*   **Memory:** None.

**Side Effects:**

*   Loads A with the current cursor character.
*   Transfers control to [FD10](#fd10-fd10).

**See also:**

*   [FD10](#fd10-fd10)
*   [KeyIn](#keyin-fd1b)
*   [RdChar](#rdchar-fd35)
*   [C3KeyIn](#c3keyin)
*   [RNDL/RNDH](#rndl-rndh)