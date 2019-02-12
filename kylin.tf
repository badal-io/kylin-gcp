resource "google_storage_bucket" "res_bucket" {
  name     = "${var.resource_bucket}"
  location = "US"
}

resource "google_storage_bucket_object" "hbase_init" {
  name   = "${var.init_action_path}/hbase.sh"
  source = "./${var.init_action_path}/hbase.sh"
  bucket = "${google_storage_bucket.res_bucket.name}"
}

resource "google_storage_bucket_object" "kylin_init" {
  name   = "${var.init_action_path}/kylin.sh"
  source = "./${var.init_action_path}/kylin.sh"
  bucket = "${google_storage_bucket.res_bucket.name}"
}

resource "google_storage_bucket_object" "hcat_init" {
  name   = "${var.init_action_path}/hive-hcatalog.sh"
  source = "./${var.init_action_path}/hive-hcatalog.sh"
  bucket = "${google_storage_bucket.res_bucket.name}"
}

resource "google_storage_bucket_object" "hue_init" {
  name   = "${var.init_action_path}/hue.sh"
  source = "./${var.init_action_path}/hue.sh"
  bucket = "${google_storage_bucket.res_bucket.name}"
}

resource "google_dataproc_cluster" "kylin" {
  name      = "kylin"
  region    = "${var.default_region}"
  cluster_config {
    gce_cluster_config{
      zone = "${var.default_zone}"
    }
    master_config {
      num_instances  = 3
    }
    worker_config {
      num_instances  = 2
    }
    initialization_action {
      script = "gs://${google_storage_bucket_object.hbase_init.bucket}/${google_storage_bucket_object.hbase_init.name}"
    }
    initialization_action {
      script = "gs://${google_storage_bucket_object.kylin_init.bucket}/${google_storage_bucket_object.kylin_init.name}"
    }
    initialization_action {
      script = "gs://${google_storage_bucket_object.hcat_init.bucket}/${google_storage_bucket_object.hcat_init.name}"
    }
    # initialization_action {
    #   script = "gs://${google_storage_bucket_object.hue_init.bucket}/${google_storage_bucket_object.hue_init.name}"
    # }
  }
}

variable "resource_bucket" {
  description = "bucket created to hold deployment resources (init_scripts,etc...)."
}
variable "init_action_path" {
  description = ""
  default = "resources/init-actions"
}
