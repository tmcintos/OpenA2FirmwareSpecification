### <a id="newbrk-fa47"></a>NewBrk ($FA47)

**Description:**

This routine stores the A register in [MACSTAT](#macstat), then pulls Y, X, and A registers from the stack before transferring control to the [Break](#break-fa4c) routine.

**Input:**

*   **Registers:**
    *   A: Current Accumulator value.
    *   X: Current X-index register value.
    *   Y: Current Y-index register value.
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Contains the value pulled from the CPU stack.
    *   X: Contains the value pulled from the CPU stack.
    *   Y: Contains the value pulled from the CPU stack.
    *   P: Undefined
*   **Memory:**
    *   [MACSTAT](#macstat): Contains the value of A register before [Break](#break-fa4c).
    *   The CPU stack is modified.

**Side Effects:**

*   Stores A register.
*   Restores Y, X, and A from stack.
*   Transfers control to [Break](#break-fa4c).

**See also:**

*   [Break](#break-fa4c)
*   [MACSTAT](#macstat)
*   [User Break Hook](#user-break-hook)