### <a id="version-fbb3"></a>Version ($FBB3)

**Description:**

This is one of the Monitor ROM's main identification bytes, a fixed hexadecimal value (`$06`) located in the ROM. It serves to indicate whether the system is an Apple //e or a later model. This byte's value is consistent across the Apple //e, enhanced Apple //e, and Apple IIGS, providing a way for software to determine the basic system type. This is not a callable routine.

**Input:** None. (This is a data location, not a routine).

**Output:** None. (This is a data location, not a routine).

**Side Effects:** None. (This is a data location, not a routine).

**See also:**

*   [ZIDByte](#zidbyte-fbc0)
*   [ZIDByte2](#zidbyte2-fbbf)