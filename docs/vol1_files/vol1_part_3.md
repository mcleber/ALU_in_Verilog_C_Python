<a id="top"></a>

| Title | Part 3 — Python  |
|-------|-------|
| File  | `vol1_part_3.md` |
| Date  | 17 Jul 2026 |

---

# Part 3 — Python

## Chapter 9 — Basic Python for automation

### 9.1 First program

File: `examples/python/hello.py`

```python
def main() -> None:
    print("Hello, Python!")


if __name__ == "__main__":
    main()
```

Run:

```bash
python3 hello.py
```

### 9.2 Why Python in this guide?

Python will be used to automate the flow.

Instead of manually typing:

```bash
gcc ...
./program
iverilog ...
vvp ...
python compare.py
```

we will do:

```bash
python3 run_all.py
```

And the script will do everything.

### 9.3 Running external commands

File: `examples/python/run_command.py`

```python
import subprocess


def run(cmd: list[str]) -> None:
    """Runs an external command.

    If the command fails, check=True makes Python raise an exception.
    This is good for automation, because it avoids continuing with a hidden error.
    """
    print("$", " ".join(cmd))
    subprocess.run(cmd, check=True)


def main() -> None:
    run(["python3", "--version"])


if __name__ == "__main__":
    main()
```

### 9.4 Working with files

File: `examples/python/write_vectors.py`

```python
from pathlib import Path


def main() -> None:
    path = Path("vectors.txt")

    with path.open("w", encoding="utf-8") as f:
        f.write("10 20 0 30\n")
        f.write("5  3  1 2\n")

    print(f"File created: {path}")


if __name__ == "__main__":
    main()
```

Each line could represent:

```text
A B OP EXPECTED_RESULT
```

This format will be used in the integrated project.

---

## Chapter 10 — Unit tests in Python

### 10.1 Simple function

File: `examples/python/math_utils.py`

```python
def add(a: int, b: int) -> int:
    return a + b


def sub(a: int, b: int) -> int:
    return a - b
```

### 10.2 Testing with unittest

File: `examples/python/test_math_utils.py`

```python
import unittest

from math_utils import add, sub


class TestMathUtils(unittest.TestCase):
    def test_add(self) -> None:
        self.assertEqual(add(2, 3), 5)
        self.assertEqual(add(-1, 1), 0)

    def test_sub(self) -> None:
        self.assertEqual(sub(10, 3), 7)
        self.assertEqual(sub(3, 10), -7)


if __name__ == "__main__":
    unittest.main()
```

Run:

```bash
python3 -m unittest -v
```

### 10.3 Why test Python?

Because Python will be responsible for automating the verification.

If the Python script has a bug, it may say the hardware passed when it actually failed.

That is why we also test the script.

---

## Chapter 11 — ALU model in Python

### 11.1 Why also build an ALU in Python?

We already have a model in C. So why create one in Python?

Because Python is excellent for:

- generating vectors quickly;
- comparing files;
- creating reports;
- trying out ideas.

The project's main reference model will be the C one, but Python will also have an educational version of the ALU for study and testing.

### 11.2 ALU implementation in Python

File: `examples/python/alu_py.py`

```python
from dataclasses import dataclass

ALU_ADD = 0
ALU_SUB = 1
ALU_AND = 2
ALU_OR = 3
ALU_XOR = 4
ALU_NOT = 5
ALU_SHL = 6
ALU_SHR = 7

@dataclass
class AluResult:
    result: int
    zero: int
    carry: int
    negative: int
    overflow: int

def mask8(value: int) -> int:
    """Keeps only the 8 least significant bits."""
    return value & 0xFF

def sign_bit(value: int) -> int:
    """Returns bit 7, used as the sign bit in 8 bits."""
    return (value >> 7) & 1

def alu_execute(a: int, b: int, op: int) -> AluResult:
    """Executes one operation of the 8-bit ALU."""
    a = mask8(a)
    b = mask8(b)

    result = 0
    carry = 0
    overflow = 0

    if op == ALU_ADD:
        temp = a + b
        result = mask8(temp)
        carry = 1 if temp > 0xFF else 0

        sa = sign_bit(a)
        sb = sign_bit(b)
        sr = sign_bit(result)
        overflow = 1 if (sa == sb and sa != sr) else 0

    elif op == ALU_SUB:
        result = mask8(a - b)
        carry = 1 if a < b else 0

        sa = sign_bit(a)
        sb = sign_bit(b)
        sr = sign_bit(result)
        overflow = 1 if (sa != sb and sa != sr) else 0

    elif op == ALU_AND:
        result = a & b

    elif op == ALU_OR:
        result = a | b

    elif op == ALU_XOR:
        result = a ^ b

    elif op == ALU_NOT:
        result = mask8(~a)

    elif op == ALU_SHL:
        carry = sign_bit(a)
        result = mask8(a << 1)

    elif op == ALU_SHR:
        carry = a & 1
        result = a >> 1

    zero = 1 if result == 0 else 0
    negative = sign_bit(result)

    return AluResult(result, zero, carry, negative, overflow)
```

### 11.3 ALU unit test in Python

File: `examples/python/test_alu_py.py`

```python
import unittest

from alu_py import (
    ALU_ADD,
    ALU_AND,
    ALU_NOT,
    ALU_OR,
    ALU_SHL,
    ALU_SHR,
    ALU_SUB,
    ALU_XOR,
    alu_execute,
)

class TestAluPy(unittest.TestCase):
    def test_add_simple(self) -> None:
        r = alu_execute(10, 20, ALU_ADD)
        self.assertEqual(r.result, 30)
        self.assertEqual(r.zero, 0)
        self.assertEqual(r.carry, 0)

    def test_add_carry(self) -> None:
        r = alu_execute(255, 1, ALU_ADD)
        self.assertEqual(r.result, 0)
        self.assertEqual(r.zero, 1)
        self.assertEqual(r.carry, 1)

    def test_sub_borrow(self) -> None:
        r = alu_execute(3, 10, ALU_SUB)
        self.assertEqual(r.result, 249)
        self.assertEqual(r.carry, 1)
        self.assertEqual(r.negative, 1)

    def test_logic(self) -> None:
        self.assertEqual(alu_execute(0xF0, 0x0F, ALU_AND).result, 0x00)
        self.assertEqual(alu_execute(0xF0, 0x0F, ALU_OR).result, 0xFF)
        self.assertEqual(alu_execute(0xAA, 0xFF, ALU_XOR).result, 0x55)
        self.assertEqual(alu_execute(0x55, 0, ALU_NOT).result, 0xAA)

    def test_shift(self) -> None:
        self.assertEqual(alu_execute(0x80, 0, ALU_SHL).result, 0x00)
        self.assertEqual(alu_execute(0x80, 0, ALU_SHL).carry, 1)
        self.assertEqual(alu_execute(0x01, 0, ALU_SHR).carry, 1)


if __name__ == "__main__":
    unittest.main()
```

Run:

```bash
python3 -m unittest -v

or

python3 -m unittest discover -v
```

---

## Chapter 12 — Concurrency and parallelism in Python

### 12.1 Threads in Python

Threads in Python are useful for input and output tasks.

Example:

```text
run several external commands
read several files
make network calls
wait for processes to finish
```

File: `examples/python/thread_example.py`

```python
from concurrent.futures import ThreadPoolExecutor
from time import sleep


def task(name: str) -> str:
    print(f"Starting task {name}")
    sleep(1)
    return f"Task {name} finished"


def main() -> None:
    names = ["A", "B", "C", "D"]

    with ThreadPoolExecutor(max_workers=4) as executor:
        results = list(executor.map(task, names))

    for r in results:
        print(r)


if __name__ == "__main__":
    main()
```

### 12.2 Processes in Python

Processes are better for CPU-heavy tasks.

File: `examples/python/process_example.py`

```python
from concurrent.futures import ProcessPoolExecutor


def square(x: int) -> int:
    return x * x


def main() -> None:
    values = list(range(10))

    with ProcessPoolExecutor() as executor:
        results = list(executor.map(square, values))

    print(results)


if __name__ == "__main__":
    main()
```

### 12.3 Generating ALU vectors in parallel

File: `examples/python/gen_vectors_parallel.py`

```python
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
```

This example generates many vectors. To start, use just a few. Then increase.

---

← [Back to Index](../README_vol1.md) | [↑ Back to top](#top)

Previous: [Part 2 — C](vol1_part_2.md) | Next: [Part 4 — Verilog](vol1_part_4.md)
