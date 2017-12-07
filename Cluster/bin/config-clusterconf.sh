#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    config-clusterconf
## Description: 一键配置脚本：配置项目cluster中的conf配置文件
## Version:     1.0
## Author:      mashencai
## Created:     2017-11-29
################################################################################
#set -x  ## 用于调试用，不用的时候可以注释掉

#---------------------------------------------------------------------#
#                              定义变量                                #
#---------------------------------------------------------------------#

cd `dirname $0`
BIN_DIR=`pwd`                                         ### bin目录：脚本所在目录
cd ..
DEPLOY_DIR=`pwd`                                      ### cluster模块部署目录
CONF_CLUSTER_DIR=$DEPLOY_DIR/conf                     ### 配置文件目录
LOG_DIR=$DEPLOY_DIR/logs                              ### log日志目录
LOG_FILE=$LOG_DIR/config-cluster.log                  ### log日志目录
cd ..
OBJECT_DIR=`pwd`                                      ### 项目根目录 
CONF_FILE=$OBJECT_DIR/project-conf.properties         ### 项目配置文件
cd ../hzgc/conf
CONF_HZGC_DIR=`pwd`                                   ### 集群配置文件目录

## 安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_HZGC_DIR}/install_home.properties)
HADOOP_INSTALL_HOME=${INSTALL_HOME}/Hadoop            ### hadoop 安装目录
HADOOP_HOME=${HADOOP_INSTALL_HOME}/hadoop             ### hadoop 根目录
HBASE_INSTALL_HOME=${INSTALL_HOME}/HBase              ### hbase 安装目录
HBASE_HOME=${HBASE_INSTALL_HOME}/hbase                ### hbase 根目录
HIVE_INSTALL_HOME=${INSTALL_HOME}/Hive                ### hive 安装目录
HIVE_HOME=${HIVE_INSTALL_HOME}/hive                  ### hive 根目录

#---------------------------------------------------------------------#
#                              定义函数                                #
#---------------------------------------------------------------------#

#####################################################################
# 函数名: move_xml
# 描述: 配置Hbase服务，移动所需文件到cluster/conf下
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function move_xml()
{
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "" | tee -a $LOG_FILE
    echo "copy 文件 hbase-site.xml core-site.xml hdfs-site.xml hive-site.xml到 cluster/conf......"  | tee  -a  $LOG_FILE

    cp ${HBASE_HOME}/conf/hbase-site.xml ${CONF_CLUSTER_DIR}
    cp ${HADOOP_HOME}/etc/hadoop/core-site.xml ${CONF_CLUSTER_DIR}
    cp ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml ${CONF_CLUSTER_DIR}
    cp ${HIVE_HOME}/conf/hive-site.xml ${CONF_CLUSTER_DIR}
    
    echo "copy完毕......"  | tee  -a  $LOG_FILE
}

#####################################################################
# 函数名: config_sparkJob
# 描述: 配置文件：cluster/conf/sparkJob.properties
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function config_sparkJob()
{
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "" | tee -a $LOG_FILE
    echo "配置cluster/conf/sparkJob 文件......"  | tee  -a  $LOG_FILE

    ### 从project-conf.properties读取sparkJob所需配置IP
    # 根据字段kafka，查找配置文件中，Kafka的安装节点所在IP端口号的值，这些值以分号分割
    KAFKA_IP=`sed '/kafka_installnode/!d;s/.*=//' ${CONF_FILE} | tr -d '\r'`
    # 将这些分号分割的ip用放入数组
    spark_arr=(${KAFKA_IP//;/ })
    sparkpro=''    
    for spark_host in ${spark_arr[@]}
    do
        sparkpro="$sparkpro$spark_host,"
    done
    sparkpro=${sparkpro%?}
    
    # 替换sparkJob.properties中：key=value（替换key字段的值value）
    sed -i "s#^kafka.metadata.broker.list=.*#kafka.metadata.broker.list=${sparkpro}#g" ${CONF_CLUSTER_DIR}/sparkJob.properties
    sed -i "s#^job.faceObjectConsumer.broker.list=.*#job.faceObjectConsumer.broker.list=${sparkpro}#g" ${CONF_CLUSTER_DIR}/sparkJob.properties
    
    echo "配置完毕......"  | tee  -a  $LOG_FILE
}

#####################################################################
# 函数名: main
# 描述: 脚本主要业务入口
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function main()
{
    move_xml
    config_sparkJob
}


#---------------------------------------------------------------------#
#                              执行流程                                #
#---------------------------------------------------------------------#

## 打印时间
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE
echo "开始配置cluster中的conf文件"                       | tee  -a  $LOG_FILE
main

set +x
