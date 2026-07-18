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
