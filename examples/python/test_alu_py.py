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
