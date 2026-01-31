### <a id="nxtchr-ffad"></a>NxtChr ($FFAD)

**Description:**

This routine plays a crucial role in parsing hexadecimal input from the Monitor's input buffer. It tests each character (starting from the offset in the Y register) to determine if it is a hexadecimal digit (`0`–`9`, `A`–`F`).

The digit test is performed by transforming the input character and comparing it against small ranges (an implementation uses an XOR with `$B0` as part of the normalization). If a valid digit is found, control passes through [Dig ($FF8A)](#dig-ff8a) to shift the digit into [A2L/A2H](#a2l-a2h).

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: The offset into the input buffer ($0200) for the character to test.
*   **Memory:**
    *   Input buffer ($0200): The start of the Monitor's input buffer.

**Output:**

*   **Registers:**
    *   A: Contains the ASCII character of the next non-hexadecimal digit encountered, or the current character if it was not a hexadecimal digit.
    *   X: Undefined.
    *   Y: The offset into the input buffer for the next character after the tested/decoded character.
    *   P: Undefined.
*   **Memory:**
    *   [A2L/A2H](#a2l-a2h) (addresses $3E-$3F): Stores the hexadecimal number decoded from the ASCII character (set by [Dig ($FF8A)](#dig-ff8a)).

**Side Effects:**

*   Processes characters from the Monitor's input buffer.
*   Stores decoded hexadecimal numbers in [A2L/A2H](#a2l-a2h).
*   When [MODE](#mode) is `$00`, each accepted digit causes the current accumulated value in `A2` to be copied into `A1` and `A3` (performed by [Dig ($FF8A)](#dig-ff8a) as part of the digit-accept flow).
*   Updates the Y register to point to the next character in the input buffer.

**Notes:**

- [Dig ($FF8A)](#dig-ff8a) is part of the hex-scanning flow and returns to `NxtChr` via a branch, not a normal `RTS` return.

**See also:**

*   [Dig ($FF8A)](#dig-ff8a)
*   [GetNum ($FFA7)](#getnum-ffa7)
*   [A2L/A2H](#a2l-a2h)