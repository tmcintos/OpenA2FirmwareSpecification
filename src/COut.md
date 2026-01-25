### <a id="cout-fded"></a>COut ($FDED)

**Description:**

This routine serves as the primary entry point for standard character output. It indirectly calls the output routine whose 16-bit address is in [CSWL/CSWH](#cswl-cswh). If enhanced video firmware is active, it routes to `C3COutl`; otherwise, to [COut1](#cout1-fdf0).

**Input:**

*   **Registers:**
    *   A: The ASCII character intended for output.
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CSWL/CSWH](#cswl-cswh) (address $36-$37): The address of the current character output routine.

**Output:**

*   **Registers:**
    *   A: Preserved
    *   X: Preserved
    *   Y: Preserved
    *   P: Undefined (flags may be affected by the ultimately called output routine).
*   **Memory:**
    *   The indirectly called output routine may modify display memory or transmit data.

**Side Effects:**

*   Transfers control to the output routine designated by [CSWL/CSWH](#cswl-cswh).
*   The ultimate output routine will display a character or execute control functions.

**See also:**

*   [COut1](#cout1-fdf0)
*   [COutZ](#coutz-fdf6)
*   [CSWL/CSWH](#cswl-cswh)
*   [SetVid](#setvid-fe93)
*   [OutPort](#outport-fe95)