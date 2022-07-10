import subprocess
import signal
import time
import os

from threading import Thread

openOnStart = "./src/bashrc_work.sh"
autoPushOnChanges = ["./src/bashrc_work.sh", "./server/initServer.sh"]
openApplication = r'C:\Program Files\Notepad++\notepad++.exe'

hashes = []
dead__ = False


def openProc():
    return subprocess.Popen([openApplication, openOnStart], start_new_session=True)


def waitUntilProcessDie(proc):
    while proc.poll() is None:
        time.sleep(0.5)


def startGitHubAutoPushThread():
    import hashlib
    def md5(file):
        hash_md5 = hashlib.md5()

        with open(file, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()

    def task():
        def save():
            print("Save")
            si = subprocess.STARTUPINFO()
            si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            subprocess.call(['git', 'add', '-A'], startupinfo=si)
            subprocess.call(['git', 'commit', '-m', 'changes'], startupinfo=si)

            d = dict(os.environ)
            d["HTTP_PROXY"] = str("http://defra1c-proxy.emea.nsn-net.net:8080")
            d["HTTPS_PROXY"] = str("http://defra1c-proxy.emea.nsn-net.net:8080")

            subprocess.call(['git', 'push'], env=d, startupinfo=si)

        def initHashes():
            global hashes
            for file in autoPushOnChanges:
                hashes.append(md5(file))

        def updateChangedFiles():
            global hashes
            updatetHashes = []
            makeSave = False
            for (file, hash) in zip(autoPushOnChanges, hashes):
                newHash = md5(file)
                updatetHashes.append(newHash)
                if newHash != hash:
                    makeSave = True
            hashes = updatetHashes
            if makeSave:
                save()

        initHashes()

        while not dead__:
            time.sleep(0.5)
            updateChangedFiles()

        updateChangedFiles()

    t = Thread(target=task)
    t.start()

def main():
    startGitHubAutoPushThread()
    proc = openProc()
    if proc.poll() is None:
        def end(signum, frame):
            proc.terminate()

        signal.signal(signal.SIGINT, end)
        signal.signal(signal.SIGILL, end)
        signal.signal(signal.SIGTERM, end)

        waitUntilProcessDie(proc)
        global dead__
        dead__ = True


if __name__ == "__main__":
    main()
