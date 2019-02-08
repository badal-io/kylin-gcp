# Kylin on GCP
This project demonstrates the use of [Apache Kylin](http://kylin.apache.org/) on
[GCP](https://cloud.google.com/gcp/) backed by [Dataproc](https://cloud.google.com/dataproc/).

## Prerequisites
To get started you will need a GCP project, to create one see [here](https://cloud.google.com/resource-manager/docs/creating-managing-projects).
This demo uses the [gcloud](https://cloud.google.com/sdk/) tool which can be
installed on your machine or accessed via [cloud shell](https://cloud.google.com/shell/).

## Demo
First, make sure the necessary GCP services are enabled for the project:
```sh
gcloud services enable dataproc.googleapis.com
```
then from either your terminal or the cloud shell environment, clone this repo:
```sh
git clone https://github.com/muvaki/kylin-to-gcp.git
cd kylin-to-gcp
```
then export the necessary variables for the deployment commands below:
```sh
export CLUSTER=kylin
export PROJECT=<PROJECT-ID>
export BUCKET=${PROJECT} # Bucket name is a suggestion only, change as needed
export MASTER="${CLUSTER}-m-2"
```
next, create and populate a bucket for resources needed for the deployment:
```sh
# create bucket
gsutil mb gs://${BUCKET}
# upload demo resources
gsutil cp -r resources gs://${BUCKET}/
```
Kylin requires a [Hadoop](https://hadoop.apache.org/) environment to compute and
store cube data. Dataproc is a managed service on GCP for running hadoop cluster
to host both Kylin and the Hadoop environment:
```sh
# create dataproc cluster
gcloud dataproc clusters create ${CLUSTER}\
  --initialization-actions gs://${BUCKET}/resources/init-actions/hbase.sh,gs://${BUCKET}/resources/init-actions/kylin.sh\
  --num-masters 3 --num-workers 2
# check status of clusters
gcloud dataproc clusters list
# view cluster instances
gcloud compute instances list
```
Once the cluster is up and running it should be ready to start Kylin on one of
the nodes; as exported above, we are using one of the masters (however any node
can be seleted):
```sh
gcloud compute ssh ${MASTER} --command="source /etc/profile && sample.sh && kylin.sh start"
```
This will will pre-populate the Kylin deployment with sample kube data and then
start the Kylin service. With Kylin installed and running yo can now tunnel to
the master node to bring up the kylin UI:
```sh
gcloud compute ssh ${MASTER} -- -L 7070:${MASTER}:7070
# then open browser to http://localhost:7070/kylin
# default creds ADMIN/KYLIN
```
From here, you should see the Kylin dashboard with a project `learn_kylin`:

 - select project `learn_kylin` in the project dropdown list (left upper corner);
 - Select the sample cube `kylin_sales_cube`, click `Actions -> Build`, pick
an `end-date` later than `2014-01-01` (to cover all 10000 sample records);
 - Check the build progress in `Monitor` tab, until 100% (refresh page as needed);
 - Execute the sample SQL query in the `Insight` tab:
```sql
select part_dt, sum(price) as total_sold, count(distinct seller_id) as sellers
from kylin_sales
group by part_dt
order by part_dt
```

At this point you have a functional kylin deployment. Other datasources can
be landed in HDFS (GCS) and [loaded into hive](https://cloud.google.com/solutions/using-apache-hive-on-cloud-dataproc#creating_a_hive_table)
using either `gcloud dataproc jobs submit hive` or by using the `hive CLI`
directly in an ssh session. Also try [creating cubes](http://kylin.apache.org/docs/tutorial/create_cube.html)
for yourself.

## Cleanup
Deleting the hadoop cluster `gcloud dataproc clusters delete ${CLUSTER}`, OR
delete the project entirely to ensure no other resources are incurring costs.

## Future Options:
- [ ] Secure cluster and access
- [ ] Autoscaling setup
- [ ] BigTable (HBase) cube storage substitution
- [ ] persistant disk HDFS substitution
- [ ] Spark substitution
- [ ] configure Kylin init-action for HA-mode (with load-balancing)
- [ ] Streaming cube (Kafka) sample
- [ ] JDBC source sample
- [ ] hadoop resource optimization (disk, cpu, preemptible workers, etc)
- [ ] cube creation sample (real-world data)
