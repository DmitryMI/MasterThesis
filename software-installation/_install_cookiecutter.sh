pip3 install cookiecutter==1.6.0

if grep -q ".local/bin" ~/.profile; then
  	echo "Cookiecutter already in .profile"
else
	echo "export PATH=\$PATH:.local/bin" >> ~/.profile
fi
