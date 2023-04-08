import os

if "venv" not in os.listdir():
    os.system("virtualenv venv --symlink-app-data --system-site-packages")
print("""run the following command in the shell: `.\\venv\Scripts\\activate`""")
