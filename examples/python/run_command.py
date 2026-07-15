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
