### SetMode ($FE18)

**Description:**

Monitor helper that updates the Monitor mode byte ([MODE](#mode)) based on a recently-parsed command character in the Monitor input buffer.

In common Monitor implementations, `SetMode` is used by the command dispatcher for the `:`, `.`, `+`, and `-` tokens.

- `:` selects store/fill behavior (subsequent parsed values are stored to memory starting at the current data pointer).
- `+` / `-` select the “expression” behavior used by the Monitor’s examine loop: the next parsed value is combined with the current address (typically `A1`) using addition or subtraction, and the result is printed.
- `.` selects an address-delimiter behavior used by some commands.

`SetMode` itself typically only records the token in `MODE`; the actual store or add/subtract operation is performed later by the main Monitor parser loop.

**Input:**

- **Registers:**
  - Y = Index into the input buffer (used to locate the previously-parsed character).
- **Memory:**
  - [INBUF](#inbuf) (Monitor input buffer; the routine reads a prior byte)
  - [MODE](#mode) (updated)

**Output:**

- **Registers:** A/Y/X undefined.
- **Memory:**
  - [MODE](#mode) updated.

**Side Effects:**

- Changes how subsequent Monitor input is interpreted.

**Notes:**

- This is an internal Monitor routine reached from the command dispatcher; it is not typically called directly by applications.

**See also:**

- [MonZ](#monz-ff69)
- [GetNum](#getnum-ffa7)
- [MODE](#mode)
