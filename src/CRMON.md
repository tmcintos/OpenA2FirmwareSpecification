### CRMon ($FEF6)

**Description:**

Monitor helper used while processing input: treats a carriage return as the end-of-line terminator and returns control to the Monitor prompt/command loop.

**Input:**

- **Registers:** A/X/Y undefined.
- **Memory:** Uses the Monitor input/parser state.

**Output:**

- Returns to the Monitor command loop rather than to the caller.

**Side Effects:**

- Discards the current command parse context and returns to [MonZ](#monz-ff69).

**Notes:**

- Many implementations handle carriage return by calling the shared $FE00 helper ([BL1](#bl1-fe00)), which adjusts the scan index and then falls into the same logic as [BLANK](#blank-fe04).
- As part of this flow, the Monitor discards the current parse context by unwinding the stack and branching back to the Monitor loop.

**See also:**

- [MonZ](#monz-ff69)
- [GetLnZ](#getlnz-fd67)
