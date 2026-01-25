### <a id="outport-fe95"></a>OutPort ($FE95)

**Description:**

This routine sets the output hooks [CSWL/CSWH](#cswl-cswh) to point to the ROM code for the port specified in the A register. Subsequent standard output will execute the ROM code at that port's entry. Calling with A = `$00` (screen display) is equivalent to calling the [SetVid](#setvid-fe93) routine.

**Input:**

*   **Registers:**
    *   A: The port number for configuration (e.g., $00-$07 for expansion slots 0-7; $00 specifically for screen display).
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   [CSWL/CSWH](#cswl-cswh) (address $36-$37): Updated with the 16-bit address of the output routine for the specified port.

**Side Effects:**

*   Modifies the system's standard output hooks.
*   Redirects subsequent standard output operations to the newly configured port's routine.

**See also:**

*   [SetVid](#setvid-fe93)
*   [CSWL/CSWH](#cswl-cswh)