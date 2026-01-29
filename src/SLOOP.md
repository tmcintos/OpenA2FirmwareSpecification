### <a id="sloop-faba"></a>SLOOP ($FABA)

**Description:**

This routine implements the disk controller slot search loop, responsible for finding and booting from a startup device. It searches for a disk controller beginning at the peripheral ROM space (if RAM disk, ROM disk, or AppleTalk has not been selected via the Control Panel as the startup device). It also considers SmartPort code for RAM/ROM disk or AppleTalk boot code in slot 7, depending on Control Panel settings. If a startup device is found, it transfers execution to that device's ROM space. If no startup device is found, the message "Check Startup Device" appears on the screen. This routine does not return to the calling program.

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:**
    *   [LOC0](#loc0) (address $00): Expected to be $00 for startup to occur.
    *   [LOC1](#loc1) (address $01): Contains `$Cn`, where `n` is the next slot number to test for a startup device.

**Output:**

*   **Registers:** None (does not return to calling program).
*   **Memory:**
    *   Screen: May display "Check Startup Device".

**Side Effects:**

*   Searches for a disk controller or other startup device.
*   Transfers execution to the ROM space of the found startup device.
*   May display "Check Startup Device" if no device is found.
*   Does not return to the calling program.

**See also:**

*   [PwrUp ($FAA6)](#pwrup-faa6) (system cold-start routine, calls SLOOP)
*   [Reset ($FA62)](#reset-fa62) (hardware reset handler, calls SLOOP)
*   [LOC0](#loc0)
*   [LOC1](#loc1)