import subprocess
import signal
import time

from threading import Thread

main_file_name = "./src/bashrc_work.sh"
notepadPPLocation = r'C:\Program Files\Notepad++\notepad++.exe'

hash__ = 0
dead__ = False


def openProc():
    return subprocess.Popen([notepadPPLocation, main_file_name], start_new_session=True)


def waitUntilProcessDie(proc):
    while proc.poll() is None:
        time.sleep(0.5)

#
def startGitHubAutoPushThread():
    import hashlib
    def md5():
        hash_md5 = hashlib.md5()
        with open(main_file_name, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()

    def task():
        def save():
            print("Save")
            subprocess.call(['git', 'add', '-A'])
            subprocess.call(['git', 'commit', '-m', 'change'])
            subprocess.call(['git', 'push'])

        def ifHashChangedPush():
            global hash__
            newHash = md5()
            if newHash == hash__:
                return
            hash__ = newHash
            save()

        global hash__
        hash__ = md5()
        while not dead__:
            time.sleep(0.5)
            ifHashChangedPush()
        ifHashChangedPush()

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
