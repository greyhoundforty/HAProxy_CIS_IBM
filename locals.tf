locals {

  env = {


    defaults = {
      app = "haproxy-tf-ans"
    }

    default {
        count = 1
    }
  }

  workspace = "${merge(local.env["defaults"], local.env[terraform.workspace])}"
  app = "${local.workspace["app"]}"

}

output "workspace" {
  value = "${terraform.workspace}"
}

output "app" {
  value = "${local.workspace["app"]}"
}

// locals {
//   dictionary_name = {
//     "key1" = "value1"
//     "key2" = "value2"
//     "key3" = "value3"
//   }
// }

// resource "local_file" "example" {
//   content = "${jsonencode(local.dictionary_name)}"
//   filename = "${path.module}/file.json"
// }

// data "external" "example" {
//   program = ["jq", ".dictionary_name", "${path.module}/file.json"]
//   query = { }

// }

// locals {
//   example_var = "${data.example.result["key1"]}"
// }