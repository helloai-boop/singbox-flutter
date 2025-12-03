#
//  install.sh
//  Runner
//
//  Created by x on 2025/11/23.
//


#!/bin/sh

#  install_helper.sh
#  V2RayX
#
#  Copyright © 2016年 Cenmrev. All rights reserved.

driver_path="$1"
sudo mkdir -p "/Library/Application Support/xxnetwork/"
sudo cp "${driver_path}" "/Library/Application Support/xxnetwork/xxnetwork"
sudo chown root:admin "/Library/Application Support/xxnetwork/xxnetwork"
sudo chmod +s "/Library/Application Support/xxnetwork/xxnetwork"
echo done
