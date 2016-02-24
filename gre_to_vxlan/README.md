step 1

# 添加组：controller 和compute 和mysqldb组
#    
#    controller 是管理服务器
#    compute    是计算节点
#    mysqdb     是数据库服务器，一般会做重合，主要考虑一下数据库操作让一台主机操作就OK
#
# 如果执行的play_book的节点无法ssh无密码登录需要添加该选项
#　例如
#　[compute]
#  10.20.0.16 ansible_ssh_user=root ansible_ssh_pass=r00tme
#  
#  或者直接填写IP地址推荐是用IP地址的形式
#
#########vars rabbitmq config #########
# 如果你的环境中有一台管理节点直接设置
#  
# rabbimq_host=manager1_ip:5673 即可
#
# 如果你的环境中有三台管理节点，需要设置变量
#
# rabbimq_host=manager1_ip:5673,manager2_ip:5673,manager3_ip:5673
#
#####################
#
#云平台网络环境注意：
# 1、公开网如果没有做bond 可以直接执行
#
# 2、如果租户网有做bond的需要先创建一下ovs网桥：

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

step 2

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
start=192.168.254.229,end=192.168.254.230 \
--gateway 192.168.254.254  \
Ext-Net-1 192.168.254.0/24  --enable_dhcp=False

















问题：
rabbitmq没有修改 ：5672


nova linuxnet_interface_修改










#
