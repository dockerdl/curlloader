#centos6-ssh
FROM centos:6
MAINTAINER dragondl <347031366@qq.com>
# 更改源为aliyun
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
RUN sed -i 's/^gpgcheck=1$/gpgcheck=0/' /etc/yum.repos.d/CentOS-Base.repo
RUN sed -i 's/^enabled=1$/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf
RUN yum makecache
# 更新系统
RUN yum update -y
# 安装supervisor
RUN yum install -y python-setuptools && yum clean all && easy_install supervisor
# 修改supervisord相关配置
RUN mkdir -p /etc/supervisor.d && echo_supervisord_conf > /etc/supervisord.conf && sed -i 's/nodaemon=false/nodaemon=true/' /etc/supervisord.conf && sed -i 's#^;\[include\]$#[include]#' /etc/supervisord.conf &&  sed -i 's#^;files.*$#files = /etc/supervisor.d/*.ini#' /etc/supervisord.conf
# 安装ssh服务
RUN yum install -y openssh-server && yum clean all
#生成ssh主机密钥
RUN mkdir -p /etc/ssh
RUN /usr/bin/ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N '' && chmod 600 /etc/ssh/ssh_host_rsa_key && chmod 644 /etc/ssh/ssh_host_rsa_key.pub
RUN /usr/bin/ssh-keygen -q -t rsa1 -f /etc/ssh/ssh_host_key -C '' -N '' && chmod 600 /etc/ssh/ssh_host_key && chmod 644 /etc/ssh/ssh_host_key.pub
RUN /usr/bin/ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N '' && chmod 600 /etc/ssh/ssh_host_dsa_key && chmod 644 /etc/ssh/ssh_host_dsa_key.pub
# 用户名，密码
RUN echo 'root:666666' | chpasswd
# 修改少量ssh配置
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
# 添加sshd相关的supervisord配置
RUN echo $'[program:sshd]\ncommand=/usr/sbin/sshd -D' > /etc/supervisor.d/sshd.ini
# 安装curl-loader服务
RUN yum install -y gcc-c++
RUN yum install -y openssl
RUN yum install -y openssl-devel
RUN yum install -y wget
RUN yum install -y bzip2
RUN yum install -y patch
RUN yum install -y tar
RUN mkdir -p /usr/curl-loader
RUN wget http://nchc.dl.sourceforge.net/project/curl-loader/curl-loader/curl-loader-0.56/curl-loader-0.56.tar.bz2
RUN tar jxvf curl-loader-0.56.tar.bz2 -C /usr/curl-loader
RUN cd /usr/curl-loader/curl-loader-0.56 &&make
RUN echo -e "PATH=$PATH:/usr/curl-loader/curl-loader-0.56" >>/etc/profile
RUN . /etc/profile
# 开放sshd端口 
EXPOSE 22
# 启动supervisord
CMD ["/usr/bin/supervisord"]

