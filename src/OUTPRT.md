### <a id="outprt-fe97"></a>OUTPRT ($FE97) (Internal)

**Description:**

This is an **internal helper routine** that is implicitly called by [OutPort](#outport-fe95) and possibly other routines. Its primary function is to initialize the X register with the address of [CSWL](#cswl-cswh) and the Y register with the low byte of the address of [COut1](#cout1-fdf0). It then unconditionally falls through to the internal `IOPRT ($FE9B)` routine. The actual logic for setting up the output hooks is handled within `IOPRT`, which uses the value previously stored in [A2L](#a2l-a2h) by [OutPort](#outport-fe95).

**Input:**

*   **Registers:** 
    *   A: N/A (routine does not use A on entry)
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [A2L](#a2l-a2h): Should contain the port number (set by [OutPort](#outport-fe95)).

**Output:**

*   **Registers:**
    *   A: Undefined (modified by subsequent calls in `IOPRT`).
    *   X: Set to the address of [CSWL](#cswl-cswh) ($36).
    *   Y: Set to the low byte of [COut1](#cout1-fdf0) address.
    *   P: Flags affected.
*   **Memory:**
    *   [CSWL/CSWH](#cswl-cswh): Updated by the `IOPRT` routine based on the port number in [A2L](#a2l-a2h).

**Side Effects:**

*   Initializes X and Y registers for use by `IOPRT`.
*   Falls through to `IOPRT ($FE9B)` which sets the output character hooks.

**Notes:**

*   This is an internal entry point not typically called directly by user programs.
*   Part of the I/O redirection infrastructure used by the Monitor.

**See also:**

*   [OutPort](#outport-fe95)
*   [IOPRT](#ioprt-fe9b)
*   [CSWL/CSWH](#cswl-cswh)
*   [A2L](#a2l-a2h)
*   [INPRT](#inprt-fe8d)
