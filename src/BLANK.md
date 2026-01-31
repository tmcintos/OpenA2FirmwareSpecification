### BLANK ($FE04)

**Description:**

Monitor parser helper used to treat a blank (space) on an input line as a separator and to continue parsing the current line.

This routine is typically reached via a shared helper at $FE00 ([BL1](#bl1-fe00)): [CRMon](#crmon-fef6) calls `BL1`, and `BL1` falls through into `BLANK` after adjusting the Monitor scan index.

**Input:**

- **Registers:**
  - A = current parsed character / mode token (Monitor internal)
  - X = Monitor parser state (used to distinguish “blank” vs other transitions)
  - Y = Monitor input index (internal)
- **Memory:**
  - [MODE](#mode) may be inspected/updated by subsequent parse logic.

**Output:**

- Returns to the Monitor parser/command loop (not intended as a stable application API).
- Registers: Undefined.

**Side Effects:**

- Affects Monitor parse flow and mode handling.

**Notes:**

- This is a Monitor-internal routine that participates in the command parser state machine; programs should not call it directly.

**See also:**

- [CRMon](#crmon-fef6)
- [MonZ](#monz-ff69)
- [MODE](#mode)
