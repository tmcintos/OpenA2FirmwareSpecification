### <a id="ioprt-fe9b"></a>IOPRT ($FE9B) (Internal)

**Description:**

This is an **internal helper routine** responsible for setting the system's input/output vectors ([KSWL/KSWH](#kswl-kswh) or [CSWL/CSWH](#cswl-cswh)). It is called by routines like [INPRT](#inprt-fe8d) (for input) and [OutPort](#outport-fe95) (for output). The behavior of this routine has evolved across ROM versions.

**In earlier ROMs (Apple II/IIe unenhanced):** This routine reads a "port number" from [A2L](#a2l), masks it, and then either loads the address of [COUT1](#cout1-fdf0) (if [A2L](#a2l) indicates slot 0 and Y register, which is assumed to contain `<KEYIN` from [INPRT](#inprt-fe8d), matches) or constructs an I/O address using `IOADR` and the slot number. This address is then stored in [LOC0](#loc0) and [LOC1](#loc1), which are subsequently used to update the relevant I/O hooks.

**In the Apple IIc ROM:** This routine (identified by its entry point address and functionality) also reads [A2L](#a2l) as its primary input. Its logic is more complex, involving conditional branches based on the value in [A2L](#a2l) (checking if it's slot 0) and the Y register (checking for a default routine like `KEYIN`). It may branch to a routine that handles PR#0 functionality ([CPRT0 ($FEC2)](#cprt0-fec2)) or to a routine that sets the I/O vectors (internal routines `IOPRT1 ($FEEE)` and `IOPRT2 ($FEAB)`, which are parts of the same flow). Ultimately, it also aims to update [LOC0](#loc0) and [LOC1](#loc1) with the address of the selected input/output routine.

**Input:**

*   **Registers:**
    *   X: Expected to contain `#<KSWL` (for input hooks) or `#<CSWL` (for output hooks).
    *   Y: Expected to contain the low byte of the default routine address (e.g., `#<KEYIN` for input, `#<COUT1` for output).
    *   A: N/A (loaded internally from memory).
*   **Memory:**
    *   [A2L](#a2l) (address $3E): The "port number" or configuration value (0 for default, or slot number 1-7).
    *   [KSWL/KSWH](#kswl-kswh) (address $38-$39): The 16-bit address of the current input routine. Modified if input hooks are being set.
    *   [CSWL/CSWH](#cswl-cswh) (address $36-$37): The 16-bit address of the current output routine. Modified if output hooks are being set.

**Output:**

*   **Registers:**
    *   A: Modified by various `lda` and `ora` operations.
    *   X: Preserved on return (after `IOPRT2`).
    *   Y: Preserved on return (after `IOPRT2`).
    *   P: Flags affected.
*   **Memory:**
    *   [LOC0](#loc0) (address $00) and [LOC1](#loc1) (address $01): Temporarily used to store the high byte of the target I/O routine address.
    *   [KSWL/KSWH](#kswl-kswh) or [CSWL/CSWH](#cswl-cswh): Updated with the address of the selected input/output routine.

**Side Effects:**

*   Determines the target input/output routine address based on [A2L](#a2l) and Y.
*   Conditionally branches to [CPRT0 ($FEC2)](#cprt0-fec2) (in Apple IIc) for specific handling related to PR#0.
*   Updates either [KSWL/KSWH](#kswl-kswh) or [CSWL/CSWH](#cswl-cswh) (depending on whether it was called by [INPRT](#inprt-fe8d) or [OutPort](#outport-fe95)) with the address of the selected I/O routine.

**See also:**

*   [INPRT](#inprt-fe8d)
*   [OutPort](#outport-fe95)
*   [A2L](#a2l)
*   [KSWL/KSWH](#kswl-kswh)
*   [CSWL/CSWH](#cswl-cswh)
*   [KeyIn](#keyin-fd1b)
*   [COUT1](#cout1-fdf0)
*   [CPRT0 ($FEC2)](#cprt0-fec2) (internal routine, Apple IIc specific behavior)
*   `IOADR`
*   [LOC0](#loc0), [LOC1](#loc1)
*   `IOPRT1 ($FEEE)` (internal routine)
*   `IOPRT2 ($FEAB)` (internal routine)