### <a id="regdsp-fad7"></a>RegDsp ($FAD7)

**Description:**

Displays the Monitor’s saved 6502 register state using the standard register display format (see [Standard register display format](#standard-register-display)).

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:**
    *   Uses the saved-register locations (for example, [A5H](#a5h), [XREG](#xreg), [YREG](#yreg), [STATUS](#status), [SPNT](#spnt)), which are commonly updated via [Save](#save-ff4a) and [Break](#break-fa4c).

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   Output stream: prints the formatted register line.

**Side Effects:**

*   Outputs a leading carriage return and then a single formatted register line (see [Standard register display format](#standard-register-display)).

**See also:**

*   [Standard register display format](#standard-register-display)
*   [REGZ](#regz-febf)
*   [Save](#save-ff4a)
*   [Restore](#restore-ff3f)
*   [Break](#break-fa4c)