### <a id="setvid-fe93"></a>SetVid ($FE93)

**Description:**

This routine sets the output links [CSWL/CSWH](#cswl-cswh) to point to the screen display routine [COut1](#cout1-fdf0). It effectively redirects all subsequent standard output operations to the video display rather than an expansion slot device.

**Hardware Details:**
This routine internally sets [A2L](#a2l-a2h) to $00 and calls [OutPort](#outport-fe95) to configure the output hooks. The effect is to reset standard output to built-in screen display output.

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
    *   [CSWL/CSWH](#cswl-cswh): Updated with the 16-bit address of the [COut1](#cout1-fdf0) routine.

**Side Effects:**

*   Modifies the system's standard output hooks.
*   Redirects subsequent standard output operations to the screen display.

**See also:**

*   [COut1](#cout1-fdf0)
*   [OutPort](#outport-fe95)
*   [CSWL/CSWH](#cswl-cswh)