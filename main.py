from core.engine import EOBoterEngine
from core.settings import Settings


def main() -> None:
    settings = Settings()
    engine = EOBoterEngine(settings)
    engine.start()


if __name__ == "__main__":
    main()
