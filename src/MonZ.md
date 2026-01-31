### <a id="monz-ff69"></a>MonZ ($FF69)

**Description:**

This routine is the primary entry point for the System Monitor, often called via `CALL -151` in Applesoft BASIC. It calls [GetLnZ](#getlnz-fd67) to display the asterisk (`*`) prompt and read input, then invokes [ZMode](#zmode-ffc7) to clear the Monitor mode flag, finally passing control to the Monitor's command-line parser. It does not return to its caller in normal operation; the Monitor continues running until a command transfers control elsewhere.

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
    *   P: Flags affected by internal operations.
*   **Memory:**
    *   [INBUF](#inbuf): Contains the user's input line.
    *   [MODE](#mode): Cleared to `$00` by [ZMode](#zmode-ffc7).

**Side Effects:**

*   Displays a Monitor prompt.
*   Reads user command input.
*   Clears the internal Monitor mode flag.
*   Enters the Monitor’s command-line parser, which can execute multiple command items from a single input line.
*   During command dispatch, the parser saves its current scan index (Y) in [YSAV](#ysav), dispatches a command handler via [TOSUB](#tosub-ffbe), then restores Y from [YSAV](#ysav) and continues scanning the remainder of the input line.

**See also:**

*   [GetLnZ](#getlnz-fd67)
*   [ZMode](#zmode-ffc7)
*   [INBUF](#inbuf)
*   [PROMPT](#prompt)
*   [MODE](#mode)