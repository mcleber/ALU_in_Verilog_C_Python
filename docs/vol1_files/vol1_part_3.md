| Title | Part 3 — Python  |
|-------|-------|
| File  | `vol1_part_3.md` |
| Date  | 15 Jul 2026 |

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














---

← [Back to Index](../README_vol1.md)

Previous: [Part 2 — C](vol1_part_2.md) | Next: [Part 4 — Verilog](vol1_part_4.md)
