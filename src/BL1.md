### BL1 ($FE00)

**Description:**

Monitor-internal helper used as a shared entry into the command-line parser’s “blank / end-of-item” handling.

This entry point is typically reached from [CRMon](#crmon-fef6) (carriage return handling), and it falls through into [BLANK](#blank-fe04) as the normal continuation. The purpose of this factoring is to share a small amount of setup logic before using the same parser state machine used for blanks.

**Input:**

- **Registers:** Monitor parser state (not intended as a general-purpose API).
- **Memory:**
  - [YSAV](#ysav) (Monitor scan index; decremented)
  - [MODE](#mode) is consulted by subsequent parser logic.

**Output:**

- Does not provide a stable register contract (Monitor-internal).
- Control continues into the parser’s shared blank/dispatch logic (see **Side Effects**).

**Side Effects:**

- Decrements [YSAV](#ysav).
- If the updated scan state indicates the current command item is complete, control transfers into the Monitor’s main item-processing logic. As part of that logic, the Monitor may:
  - perform memory examine output, or
  - perform the `+` / `-` “expression” behavior (combine the next parsed value with the current address value and print the result), depending on [MODE](#mode).
- Otherwise, it falls through into [BLANK](#blank-fe04).

**Notes:**

- This entry point exists in multiple Monitor implementations and is a key part of how `CR` and blank handling share the same small parse/dispatch path.
- Although ROM disassemblies often label the follow-on decision point as `XAMPM`, the externally observable contract is simply the Monitor’s documented behavior for examine/store/add/subtract modes; the specific internal label is not a required part of a compatible implementation.

**See also:**

- [CRMon](#crmon-fef6)
- [BLANK](#blank-fe04)
- [SetMode](#setmode-fe18) (sets [MODE](#mode) for `:`, `.`, `+`, `-` tokens)
- [MonZ](#monz-ff69)
- [MODE](#mode)
- [YSAV](#ysav)
