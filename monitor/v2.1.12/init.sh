#!/bin/sh
if [ ! -d $GF_PROVISIONING_PATH/dashboards  ];then
    mkdir -p $GF_PROVISIONING_PATH/dashboards
else
    rm -rf  $GF_PROVISIONING_PATH/dashboards/*
fi

# TiDB dashboard
cp /tmp/tidb.json $GF_PROVISIONING_PATH/dashboards
sed -i 's/Test-Cluster-TiDB/'$TIDB_CLUSTER_NAME'-TiDB/g'  $GF_PROVISIONING_PATH/dashboards/tidb.json

# Overview dashboard
cp /tmp/overview.json $GF_PROVISIONING_PATH/dashboards
sed -i 's/Test-Cluster-Overview/'$TIDB_CLUSTER_NAME'-Overview/g' $GF_PROVISIONING_PATH/dashboards/overview.json

# PD dashboard
cp /tmp/pd.json $GF_PROVISIONING_PATH/dashboards
sed -i 's/Test-Cluster-PD/'$TIDB_CLUSTER_NAME'-PD/g' $GF_PROVISIONING_PATH/dashboards/pd.json

# TiKV dashboard
cp /tmp/tikv*.json $GF_PROVISIONING_PATH/dashboards
if [ ! -f /tmp/tikv_pull.json ];then
    sed -i 's/Test-Cluster-TiKV-Details/'$TIDB_CLUSTER_NAME'-TiKV-Details/g' $GF_PROVISIONING_PATH/dashboards/tikv_details.json
    sed -i 's/Test-Cluster-TiKV-Summary/'$TIDB_CLUSTER_NAME'-TiKV-Summary/g' $GF_PROVISIONING_PATH/dashboards/tikv_summary.json
    sed -i 's/Test-Cluster-TiKV-Trouble-Shooting/'$TIDB_CLUSTER_NAME'-TiKV-Trouble-Shooting/g' $GF_PROVISIONING_PATH/dashboards/tikv_trouble_shooting.json
else
    sed -i 's/Test-Cluster-TiKV/'$TIDB_CLUSTER_NAME'-TiKV/g'  $GF_PROVISIONING_PATH/dashboards/tikv_pull.json
fi

# Binlog dashboard
if $TIDB_ENABLE_BINLOG
then
    cp /tmp/binlog.json $GF_PROVISIONING_PATH/dashboards
    sed -i 's/Test-Cluster-Binlog/'$TIDB_CLUSTER_NAME'-Binlog/g'  $GF_PROVISIONING_PATH/dashboards/binlog.json
fi

# Rules
if [ ! -d $PROM_CONFIG_PATH/rules  ];then
    mkdir -p $PROM_CONFIG_PATH/rules
else
    rm -rf  $PROM_CONFIG_PATH/rules/*
fi
echo $META_TYPE
echo $META_INSTANCE
echo $META_VALUE
cp /tmp/*.rules.yml $PROM_CONFIG_PATH/rules
for file in $PROM_CONFIG_PATH/rules/*
do
    sed -i 's/ENV_LABELS_ENV/'$TIDB_CLUSTER_NAME'/g' $file
done

# Datasources
if [ $GF_DATASOURCE_PATH ];
then
    if [ $GF_NODE_EXPORTER_DATASOURCE_URL ];
    then
        sed -i 's,http://prometheus-k8s.monitoring.svc:9090,'$GF_NODE_EXPORTER_DATASOURCE_URL',g' /tmp/disk-datasource.yaml
    fi

    if [ $GF_TIDB_CLUSTER_URL ];
    then
        sed -i 's,http://127.0.0.1:9090,'$GF_TIDB_CLUSTER_URL',g' /tmp/tidb-cluster-datasource.yaml
    fi

    cp /tmp/disk-datasource.yaml $GF_DATASOURCE_PATH/
    cp /tmp/tidb-cluster-datasource.yaml $GF_DATASOURCE_PATH/
    sed -i 's/Test-Cluster-Disk-Performance/'$TIDB_CLUSTER_NAME'-Disk-Performance/g' /tmp/disk-datasource.yaml
    cp /tmp/node-disk-dashboard.json $GF_PROVISIONING_PATH/dashboards
fi

