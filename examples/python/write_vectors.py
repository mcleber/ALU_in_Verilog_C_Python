from pathlib import Path


def main() -> None:
    path = Path("vectors.txt")

    with path.open("w", encoding="utf-8") as f:
        f.write("10 20 0 30\n")
        f.write("5  3  1 2\n")

    print(f"File created: {path}")


if __name__ == "__main__":
    main()
