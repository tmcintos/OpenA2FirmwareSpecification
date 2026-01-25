### <a id="keyin0-fd18"></a>KeyIn0 ($FD18)

**Description:**

This routine is an alternative entry point for standard keyboard input. It unconditionally jumps to the routine whose 16-bit address is in [KSWL/KSWH](#kswl-kswh) (typically [KeyIn](#keyin-fd1b) or `C3KeyIn`). Functionally identical to [FD10](#fd10-fd10).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Undefined
    *   Y: Undefined
    *   P: Flags affected
*   **Memory:**
    *   Modifications depend on the routine to which control is passed.

**Side Effects:**

*   Transfers control to the input routine specified by [KSWL/KSWH](#kswl-kswh).
*   Side effects are those of the called routine.

**See also:**

*   [KeyIn](#keyin-fd1b)
*   [FD10](#fd10-fd10)
*   [C3KeyIn](#c3keyin)
*   [KSWL/KSWH](#kswl-kswh)