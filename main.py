from core.engine import EOBoterEngine
from core.settings import Settings
def main():
    engine=EOBoterEngine(Settings.from_env()); engine.start()
if __name__=="__main__": main()
