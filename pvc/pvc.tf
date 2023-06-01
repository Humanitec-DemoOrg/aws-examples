resource "humanitec_resource_definition" "pvc" {
  driver_type = "humanitec/volume-pvc"
  id          = "myvolume"
  name        = "myvolume"
  type        = "volume"

  driver_inputs = {
    secrets = {
    },
    values = {
      "access_modes" : "ReadWriteOnce",
      "capacity" : "10Gi",
      "storage_class_name" : "gp2"
    }
  }

}

