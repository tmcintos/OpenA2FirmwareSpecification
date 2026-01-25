### <a id="dopr0-fece"></a>DOPR0 ($FECE) (Internal)

**Description:**

This is an **internal helper routine** branched to by `CPRT0 ($FEC2)` as part of a "PR#0" (print to slot 0, usually meaning the screen) operation. It sets the `VFACTV` flag to indicate that the video firmware is inactive, switches the character set to normal, and modifies the `VMODE` setting. It then saves the X and Y registers on the stack before calling `CHK80 ($CDCD)` to conditionally switch to 40-column mode if the system was previously in 80-column mode. Finally, it restores the X and Y registers from the stack and flows into `IOPRT1 ($FEEE)`, which continues the process of setting output hooks to the default video output routine ([COUT1](#cout1-fdf0)).

**Input:**

*   **Registers:** A (expected to contain `#$F7` from `CPRT0`, used to set `VFACTV` and `CLRALTCHAR`).
*   **Memory:**
    *   [VMODE](#vmode) (address $04FB): Its current state is read and modified by `tsb VMODE`.
    *   `RD80VID ($C01F)`: Soft switch read by [CHK80](#chk80-cdcd).
    *   `RDTEXT ($C01A)`: Soft switch read by [WIN0](#win0-cdd5) (part of `CHK80`'s flow).

**Output:**

*   **Registers:**
    *   A: Modified (contains `>COUT1` before flowing to `IOPRT1`).
    *   X: Preserved (pushed and pulled from stack).
    *   Y: Preserved (pushed and pulled from stack).
    *   P: Flags affected by various operations.
*   **Memory:**
    *   [VFACTV](#vfactv) (address $067B): Set to the value of A (effectively `$F7`).
    *   `CLRALTCHAR ($C00E)`: Soft switch, set to the value of A (effectively `$F7`).
    *   [VMODE](#vmode) (address $04FB): Modified by `tsb VMODE` (setting bit 2, which corresponds to M.CTL).
    *   [WNDTOP](#wndtop) (address $22): May be modified by [WIN0](#win0-cdd5) within `CHK80`.
    *   [WNDWDTH](#wndwdth) (address $21): May be modified by [WIN0](#win0-cdd5) within `CHK80`.
    *   [KSWL/KSWH](#kswl-kswh) or [CSWL/CSWH](#cswl-cswh): Updated by `IOPRT2` (part of `IOPRT1`'s flow).

**Side Effects:**

*   Sets `VFACTV` to indicate video firmware inactivity.
*   Activates the normal character set (`CLRALTCHAR` soft switch).
*   Sets the M.CTL bit in `VMODE`.
*   Calls [CHK80](#chk80-cdcd) to handle column mode conversion.
*   Flows into `IOPRT1 ($FEEE)` to set up output hooks, ultimately directing output to [COUT1](#cout1-fdf0).

**See also:**

*   `CPRT0 ($FEC2)` (internal routine)
*   [CHK80](#chk80-cdcd) (internal routine)
*   [VFACTV](#vfactv)
*   [CLRALTCHAR](#clraltchar) (soft switch)
*   [VMODE](#vmode)
*   [COUT1](#cout1-fdf0)
*   `IOPRT1 ($FEEE)` (internal routine)
*   `IOPRT2 ($FEAB)` (internal routine)
*   [WNDTOP](#wndtop), [WNDWDTH](#wndwdth), [RDTEXT](#rdtext), [RD80VID](#rd80vid), [SETX](#setx) (accessed via [CHK80](#chk80-cdcd))