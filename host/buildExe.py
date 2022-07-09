import os

os.system("pyinstaller ./host/bashrcController.py -F --onefile --distpath ./ --clean -n bashrc.txt")
