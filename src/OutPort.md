### <a id="outport-fe95"></a>OutPort ($FE95)

**Description:**

This routine stores the value from the A register into the zero-page location [A2L](#a2l-a2h). It then falls through to the internal `OUTPRT ($FE97)` routine. The `OUTPRT` routine is responsible for setting the system's output hooks ([CSWL/CSWH](#cswl-cswh)) based on the value found in [A2L](#a2l-a2h), effectively allowing the output destination to be directed to a specified port. Calling with A = `$00` (screen display) is equivalent to calling the [SetVid](#setvid-fe93) routine.

**Input:**

*   **Registers:**
    *   A: Contains the value (typically a port number, $00 for screen display) to be used for setting the output hooks.
    *   X: N/A
    *   Y: N/A
*   **Memory:** N/A (the routine primarily acts on its A register input).

**Output:**

*   **Registers:**
    *   A: Undefined (modified by subsequent calls from `OUTPRT`).
    *   X: Undefined (modified by subsequent calls from `OUTPRT`).
    *   Y: Undefined (modified by subsequent calls from `OUTPRT`).
    *   P: Flags affected.
*   **Memory:**
    *   [A2L](#a2l-a2h) (address $3E): Stored with the value from the A register.
    *   [CSWL/CSWH](#cswl-cswh) (address $36-$37): Updated by the `OUTPRT ($FE97)` routine.

**Side Effects:**

*   Stores the input value from A to [A2L](#a2l-a2h).
*   Transfers control to the internal `OUTPRT ($FE97)` routine, which then modifies the system's standard output hooks.

**See also:**

*   `OUTPRT ($FE97)` (internal routine)
*   [SetVid](#setvid-fe93)
*   [CSWL/CSWH](#cswl-cswh)
*   [A2L](#a2l-a2h)