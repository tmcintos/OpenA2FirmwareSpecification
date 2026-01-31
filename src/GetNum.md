### <a id="getnum-ffa7"></a>GetNum ($FFA7)

**Description:**

This routine scans the Monitor’s input buffer, starting at the offset specified in the Y register. It decodes consecutive hexadecimal digits and accumulates the value into the 16-bit register [A2L/A2H](#a2l-a2h) ($3E/$3F). Scanning continues until a character is encountered that is not a hexadecimal digit. `GetNum` relies on [NxtChr ($FFAD)](#nxtchr-ffad) (and its helper [Dig ($FF8A)](#dig-ff8a)) to recognize and decode digits.

Because the accumulator is only 16 bits wide, each additional hex digit shifts the current value left by 4 bits and inserts the new nibble; if more than four digits are supplied, the high bits are discarded and the final value naturally ends up as the last four hex digits. When a caller uses only the low byte ([A2L](#a2l-a2h)) as the result, the effect is similarly “last two hex digits.”

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