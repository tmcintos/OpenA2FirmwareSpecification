### <a id="monz4-ff70"></a>MonZ4 ($FF70)

**Description:**

This routine is an alternative entry point to the System Monitor, similar to [MonZ](#monz-ff69). `MonZ4` does not automatically call [GetLnZ](#getlnz-fd67) or [ZMode](#zmode-ffc7). Programs using `MonZ4` must first read input and clear the Monitor mode flag before transferring control.

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
    *   P: Flags affected by Monitor operations.
*   **Memory:**
    *   Memory modifications depend on the commands parsed and executed by the Monitor.

**Side Effects:**

*   Enters the System Monitor, bypassing initial prompt display and mode clearing.
*   Processes commands already present in the Monitor's input buffer.

**See also:**

*   [MonZ](#monz-ff69)
*   [GetLnZ](#getlnz-fd67)
*   [ZMode](#zmode-ffc7)
*   [INBUF](#inbuf)
*   [MODE](#mode)