OMPP_LINK="https://github.com/omnetpp/omnetpp/releases/download/omnetpp-5.7/omnetpp-5.7-linux-x86_64.tgz"

wget --directory-prefix=~/Downloads/ $OMPP_LINK

tar -xzf ~/Downloads/omnetpp-5.7-linux-x86_64.tgz -C $INSTALLATION_DIR

backup_wd = $(pwd)

cd $INSTALLATION_DIR/omnetpp-5.7

source setenv

./configure

make -j 16

echo "export PATH=\$PATH:$INSTALLATION_DIR/omnetpp-5.7/bin" >> ~/.profile

cd $backup_wd
