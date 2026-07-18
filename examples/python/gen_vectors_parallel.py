from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

from alu_py import alu_execute


OPS = list(range(8))


def make_line(args: tuple[int, int, int]) -> str:
    a, b, op = args
    r = alu_execute(a, b, op)

    return (
        f"{a:02X} {b:02X} {op:X} "
        f"{r.result:02X} {r.zero} {r.carry} {r.negative} {r.overflow}\n"
    )


def main() -> None:
    tests: list[tuple[int, int, int]] = []

    for a in range(256):
        for b in range(256):
            for op in OPS:
                tests.append((a, b, op))

    with ProcessPoolExecutor() as executor:
        lines = list(executor.map(make_line, tests))

    Path("alu_vectors_py.txt").write_text("".join(lines), encoding="utf-8")
    print(f"Generated {len(lines)} vectors.")


if __name__ == "__main__":
    main()
