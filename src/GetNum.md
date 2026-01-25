### <a id="getnum-ffa7"></a>GetNum ($FFA7)

**Description:**

This routine scans the Monitor’s input buffer, starting at the offset specified in the Y register. It decodes ASCII codes representing hexadecimal numbers into their corresponding hexadecimal values and stores them in the zero-page locations [A2L/A2H](#a2l-a2h) ($3E/$3F). The scanning continues until it encounters an ASCII code that is not a valid hexadecimal digit. `GetNum` relies on [NxtChr ($FFAD)](#nxtchr-ffad) to test, parse, and decode these hexadecimal numbers.

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: The offset into the input buffer ($0200) where scanning for hexadecimal digits should begin.
*   **Memory:**
    *   Input buffer ($0200): The start of the Monitor's input buffer.

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: The offset into the input buffer for the next character after the decoded hexadecimal number.
    *   P: Undefined.
*   **Memory:**
    *   [A2L/A2H](#a2l-a2h) (addresses $3E-$3F): Stores the hexadecimal number decoded from the input buffer.

**Side Effects:**

*   Reads and processes characters from the Monitor's input buffer.
*   Converts ASCII hexadecimal digits to their numerical equivalent.
*   Stores the result in [A2L/A2H](#a2l-a2h).
*   Updates the Y register to point to the next character in the input buffer.

**See also:**

*   [NxtChr ($FFAD)](#nxtchr-ffad)
*   [A2L/A2H](#a2l-a2h)