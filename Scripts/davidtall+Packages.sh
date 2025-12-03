#!/bin/bash

#不编译xray-core
sed -i 's/+xray-core//' luci-app-passwall2/Makefile

#删除官方的默认插件
#*****************************
#删除dockerman
#*****************************
rm -rf ../feeds/luci/applications/luci-app-{passwall*,mosdns,dae*,bypass*}
rm -rf ../feeds/packages/net/{v2ray-geodata,dae*}

#更新golang为最新版
rm -rf ../feeds/packages/lang/golang
git clone -b 24.x https://github.com/sbwml/packages_lang_golang ../feeds/packages/lang/golang


cp -r $GITHUB_WORKSPACE/package/* ./

#coremark修复
sed -i 's/mkdir \$(PKG_BUILD_DIR)\/\$(ARCH)/mkdir -p \$(PKG_BUILD_DIR)\/\$(ARCH)/g' ../feeds/packages/utils/coremark/Makefile

#修改字体
#argon_css_file=$(find ./luci-theme-argon/ -type f -name "cascade.css")
#sed -i "/^.main .main-left .nav li a {/,/^}/ { /font-weight: bolder/d }" $argon_css_file
#sed -i '/^\[data-page="admin-system-opkg"\] #maincontent>.container {/,/}/ s/font-weight: 600;/font-weight: normal;/' $argon_css_file

#修复daed/Makefile
#rm -rf luci-app-daed/daed/Makefile && cp -r $GITHUB_WORKSPACE/patches/daed/Makefile luci-app-daed/daed/
#cat luci-app-daed/daed/Makefile
