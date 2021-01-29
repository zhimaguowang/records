# 高级防火墙最小化设置 #

## 必须开启的项目 ##

### 入站 ###

~1. 核心网络组：核心网络 - 动态主机配置协议(DHCP-In)~

~*未开启此规则时，手机连接到“移动热点”后，将无法获得IP地址。*~

2. 自定义：Sockets 5 代理工具的入站连接

*添加此规则后，局域网中通过“移动热点”连接的手机，才能正常使用远程代理。*

### 出站 ###

1. 核心网络组：核心网络 – DNS (UDP-Out)

*此规则开启后，才能正确使用DNS解析。若不开启，无法使用浏览器访问网站。*

2. 核心网络组：核心网络 - 动态主机配置协议(DHCP-Out)

*此规则开启后，每次开机才能自动获得路由器分配的IP地址。（固定IP地址的情况，似乎也可不予开启，但未实验是否影响“移动热点”的使用。）*

3. 自定义：Internet Connection Sharing (ICS) 

选择，`程序： C:\windows\system32\svchost.exe ` 和 ` 服务： Internet Connection Sharing (ICS)`
Internet Connection Sharing 短名称为 “SharedAccess”

*未开启此规则，连接到“移动热点”后无法获得IP地址。*

4. 自定义：Microsoft Malware Protection Command Line Utility (mpcmdrun.exe)

选择， `程序： C:\programdata\microsoft\windows defender\platform\4.18.2011.6-0\mpcmdrun.exe`

*此规则为开启 Windows Defender 杀软升级，关闭后，杀毒软件无法联网更新。*

5. 自定义：Microsoft Edge

选择， `程序： C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe`

*此规则开启后，Edge 浏览器才能访问互联网。*

--------

通过“移动热点”来开启局域网的 Sockets5 代理，需要开启下面三条规则。

入站：`Sockets5代理工具`访问权限

出站：`Sockets5代理工具`访问权限  和 `Internet Connection Sharing (ICS)服务`访问权限 

另外，Socket5代理工具，必须使用`0.0.0.0 广播`，而不是`127.0.0.1 本地`。
