### <a id="inprt-fe8d"></a>INPRT ($FE8D) (Internal)

**Description:**

This is an **internal helper routine** that is implicitly called by [InPort](#inport-fe8b) and possibly other routines. Its primary function is to initialize the X register with the address of [KSWL](#kswl-kswh) and the Y register with the low byte of the address of [KeyIn](#keyin-fd1b). It then unconditionally branches to the internal `IOPRT ($FE9B)` routine. The actual logic for setting up the input hooks is handled within `IOPRT`, which uses the value previously stored in [A2L](#a2l-a2h) by [InPort](#inport-fe8b).

**Input:**

*   **Registers:** N/A (registers X and Y are initialized internally).
*   **Memory:**
    *   [A2L](#a2l-a2h) (address $3E): Contains the value (port number) that will be used by the subsequent `IOPRT` routine to determine which input routine to set.

**Output:**

*   **Registers:**
    *   A: Modified by `IOPRT`.
    *   X: Initialized to `#<KSWL` (the low byte of the address of [KSWL](#kswl-kswh)), then modified by `IOPRT`.
    *   Y: Initialized to `#<KEYIN` (the low byte of the address of [KeyIn](#keyin-fd1b)), then modified by `IOPRT`.
    *   P: Flags affected.
*   **Memory:**
    *   [KSWL/KSWH](#kswl-kswh) (address $38-$39): Updated by the `IOPRT ($FE9B)` routine.

**Side Effects:**

*   Initializes X and Y registers with pointer-related values.
*   Transfers control to the internal `IOPRT ($FE9B)` routine.
*   The system's standard input hooks ([KSWL/KSWH](#kswl-kswh)) are modified by `IOPRT`.

**See also:**

*   [InPort](#inport-fe8b)
*   `IOPRT ($FE9B)` (internal routine)
*   [KSWL/KSWH](#kswl-kswh)
*   [KeyIn](#keyin-fd1b)
*   [A2L](#a2l-a2h)