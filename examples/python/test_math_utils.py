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
