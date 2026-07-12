"""Small Day 2 helper for binary, hex, and two's-complement practice."""


def unsigned_to_binary(value: int, width: int) -> str:
    if value < 0 or value >= 2**width:
        raise ValueError(f"{value} does not fit in {width} unsigned bits")
    return format(value, f"0{width}b")


def signed_to_twos_complement(value: int, width: int) -> str:
    minimum = -(2 ** (width - 1))
    maximum = 2 ** (width - 1) - 1
    if value < minimum or value > maximum:
        raise ValueError(f"{value} does not fit in {width} signed bits")
    if value < 0:
        value = 2**width + value
    return format(value, f"0{width}b")


def twos_complement_to_signed(bits: str) -> int:
    width = len(bits)
    value = int(bits, 2)
    if bits[0] == "1":
        value -= 2**width
    return value


def print_examples() -> None:
    print("Unsigned examples")
    for value in [0, 5, 10, 15, 31, 165]:
        width = 8
        print(f"{value:>4} decimal = 0b{unsigned_to_binary(value, width)} = 0x{value:02X}")

    print()
    print("8-bit two's-complement examples")
    for value in [12, 5, 0, -1, -5, -128]:
        bits = signed_to_twos_complement(value, 8)
        decoded = twos_complement_to_signed(bits)
        print(f"{value:>4} decimal = 0b{bits}; decoded back = {decoded}")


if __name__ == "__main__":
    print_examples()
