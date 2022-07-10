This script updates you server bashrc while you change it locally   

Install on server
```
git clone https://github.com/watislaf/bashrc_work.git
bash ./bashrc_work/server/initServer.sh
```

Install on host
```
git clone https://github.com/watislaf/bashrc_work.git
cd bashrc_work/
./venv/Scripts/activate
python ./host/buildExe.py
```
