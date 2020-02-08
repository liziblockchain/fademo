#!/bin/bash

cd lizibase/java/
rm -rf target/ wallet/
cd ..
#rm netconfig-org1.yaml
cd ..

baktime=$(date "+%Y%m%d_%H%M%S")

filename=zlizibase.$baktime.tar.gz
#echo $filename

tar zcvf $filename lizibase
