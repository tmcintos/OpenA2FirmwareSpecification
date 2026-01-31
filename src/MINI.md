### Mini ($FE6C)

**Description:**

Monitor command handler that enters a built-in mini-assembler, when a mini-assembler is provided as part of the system firmware.

**Input:**

- **Registers / Memory:** Monitor parser state.

**Output:**

- **Registers:** Undefined.

**Side Effects:**

- Enters the mini-assembler user interface.

**Notes:**

- A mini-assembler is not guaranteed to exist on all Apple II-family systems. Where it exists, it is a Monitor feature.
- Some systems instead provide similar assembler functionality outside the main system firmware; that external functionality is outside the scope of this specification.

**See also:**

- [MonZ](#monz-ff69)
