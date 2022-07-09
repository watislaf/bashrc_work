import os

os.system("pyinstaller ./host/bashrcController.py -F --onefile --distpath ./ --clean -n bashrc.txt")
x = open("secrets.txt","w")
x.write("PASTE_YOUR_GITHUB_TOKEN_HERE\n")