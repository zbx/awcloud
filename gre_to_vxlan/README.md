


host文件配置
# 匹配host格式：
# [controller]
# node-[1:2] ansible_ssh_user=root ansible_ssh_pass=r00tme
#  或者直接填写IP地址

#云平台网络环境注意：
#1、公开网如果没有做bond 可以直接执行
#
2、如果租户网有做bond的需要先创建一下ovs网桥：

ovs-vsctl add-br br-p

ovs-vsctl add-port br-ovs-bond0 br-ovs-bond0-br-p
ovs-vsctl set interface br-ovs-bond0-br-p type=patch

ovs-vsctl add-port br-p br-p-br-ovs-bond0
ovs-vsctl set interface br-p-br-ovs-bond0 type=patch

ovs-vsctl set interface br-ovs-bond0-br-p options:peer=br-p-br-ovs-bond0
ovs-vsctl set interface br-p-br-ovs-bond0 options:peer=br-ovs-bond0-br-p

#vim ~/roles/ConfigVxlan/veth-peers.sh
#修改netdev_prv=br-p
#
#根据新的physnet2的映射，修改下面的文件
#vim /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
physical_interface_mappings = physnet1:br-ex-lb


#重启linuxbrige-agent
#
#
#    1、添加组：controller 和compute 和mysqldb组
#    
#    controller 是管理服务器
#    compute    是计算节点
#    mysqdb     是数据库服务器，一般会做重合，主要考虑一下数据库操作让一台主机操作就OK
#    
#    
#    2、执行：
#    ansible-playbook -i hosts site.yml 
#    
#    参数：
#    --list-hosts     查看匹配到的主机
#    --syntax-check   检查配置文件正确性
#    --step           单进程一步一步执行
#    -f ID            多进程并发执行 ID 是并发数量



配置完毕后操作：


删除云平台所有交换机和路由器，包括外网交换机



手动创建：
neutron net-create Ext-Net-1 \
--provider:network_type flat \
--provider:physical_network physnet1 \
--router:external true --shared


neutron subnet-create  \
--allocation-pool \
start=103.227.79.135,end=103.227.79.254 \
--gateway 103.227.79.129  \
Ext-Net-1 103.227.79.128/25  --enable_dhcp=False




























#
