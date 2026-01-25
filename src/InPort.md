### <a id="inport-fe8b"></a>InPort ($FE8B)

**Description:**

This routine stores the value from the A register into the zero-page location [A2L](#a2l). It then implicitly transfers control to the internal `INPRT ($FE8D)` routine. The `INPRT` routine is responsible for setting the system's input hooks ([KSWL/KSWH](#kswl-kswh)) based on the value found in [A2L](#a2l), effectively allowing the input source to be directed to a specified port.

**Input:**

*   **Registers:**
    *   A: Contains the value (typically a port number, $00 for keyboard) to be used for setting the input hooks.
    *   X: N/A
    *   Y: N/A
*   **Memory:** N/A (the routine primarily acts on its A register input).

**Output:**

*   **Registers:**
    *   A: Preserved (after its value is stored, but later modified by subsequent calls from `INPRT`).
    *   X: Modified by subsequent calls from `INPRT`.
    *   Y: Modified by subsequent calls from `INPRT`.
    *   P: Flags affected.
*   **Memory:**
    *   [A2L](#a2l) (address $3E): Stored with the value from the A register.
    *   [KSWL/KSWH](#kswl-kswh) (address $38-$39): Updated by the `INPRT ($FE8D)` routine.

**Side Effects:**

*   Stores the input value from A to [A2L](#a2l).
*   Transfers control to the internal `INPRT ($FE8D)` routine, which then modifies the system's standard input hooks.

**See also:**

*   `INPRT ($FE8D)` (internal routine)
*   [KSWL/KSWH](#kswl-kswh)
*   [A2L](#a2l)
*   [SetKbd](#setkbd-fe89)