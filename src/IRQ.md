### <a id="irq-fa40"></a>IRQ ($FA40)

**Description:**

This routine serves as a jump to the system's interrupt-handling routines for IRQs (Interrupt ReQuests) and BRKs (Break instructions). After the application's installed interrupt routines complete and perform an RTI (Return from Interrupt), all 6502 registers are restored to their pre-interrupt state. Notably, unlike in earlier Apple II models, location `$45` is specifically preserved, ensuring its value is not inadvertently destroyed during interrupt processing.

**Note (Variant Difference):** In the original Apple II firmware, the IRQ handler is located at $FA86 rather than $FA40. Later systems (Apple II+, IIe, IIc) standardized on the $FA40 address documented here.

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:** N/A (The state of the system and registers are captured by the interrupt mechanism upon entry).

**Output:**

*   **Registers:**
    *   A: Preserved.
    *   X: Preserved.
    *   Y: Preserved.
    *   P: Preserved.
*   **Memory:** N/A.

**Side Effects:**

*   Transfers control to interrupt-handling routines.
*   Restores all 6502 registers after an RTI.
*   Preserves the content of memory location `$45`.

**See also:**

*   [IRQLOC](#irqloc)