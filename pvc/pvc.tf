resource "humanitec_resource_definition" "pvc" {
  driver_type = "humanitec/volume-pvc"
  id          = "volume"
  name        = "volume"
  type        = "volume"

  driver_inputs = {
    values = {
      "access_modes" : "ReadWriteOnce",
      "capacity" : "10Gi",
      "storage_class_name" : "gp2"
    }
  }

}

resource "humanitec_resource_definition" "efs" {
  driver_type = "humanitec/volume-pvc"
  id          = "volume-efs"
  name        = "volume-efs"
  type        = "volume"

  driver_inputs = {
    values = {
      "access_modes" : "ReadWriteMany",
      "capacity" : "10Gi",
      "storage_class_name" : "efs-fc"
    }
  }

}
