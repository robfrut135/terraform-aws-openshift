data "template_file" "openshift_applier" {
  template = "${file("${path.module}/resources/openshift-applier.sh")}"

  vars {
    platform_name       = "${var.platform_name}"
    platform_aws_region = "${data.aws_region.current.name}"
  }
}

resource "null_resource" "openshift_applier" {
  provisioner "file" {
    source      = "${path.module}/resources/openshift-applier"
    destination = "~"
  }

  provisioner "file" {
    content     = "${data.template_file.openshift_applier.rendered}"
    destination = "~/openshift-applier.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/openshift-applier.sh",
      "sh ~/openshift-applier.sh",
    ]
  }

  connection {
    type        = "ssh"
    user        = "${var.bastion_ssh_user}"
    private_key = "${var.platform_private_key}"
    host        = "${var.bastion_endpoint}"
  }

  triggers {
    inventory = "${data.template_file.template_inventory.rendered}"
    script    = "${data.template_file.openshift_applier.rendered}"
  }

  depends_on = ["null_resource.main"]
}
