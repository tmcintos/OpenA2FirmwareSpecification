### <a id="getln1-fd6f"></a>GetLn1 ($FD6F)

**Description:**

This routine serves as an entry point for keyboard input. It initializes the X register with a value of $01$ and then flows into the [GetLnZ ($FD67)](#getlnz-fd67) routine to handle the actual line input. Unlike [GetLn ($FD6A)](#getln-fd6a), this entry point does not display an initial prompt character.

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Set to $01$.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:** None.

**Side Effects:**

*   Initializes the X register to $01$.
*   Transfers control to [GetLnZ ($FD67)](#getlnz-fd67).

**See also:**

*   [GetLn ($FD6A)](#getln-fd6a)
*   [GetLnZ ($FD67)](#getlnz-fd67)
