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
