import os

os.system("pyinstaller ./host/bashrcController.py -F --noconsole --onefile --distpath ./ --clean -n bashrc.txt")
