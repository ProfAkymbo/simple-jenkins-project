# This block creates the web servers using the "aws_instance" resource. 
# We're using the AMI ID that we fetched earlier, setting the instance type using the "instance_type" variable, and deploying the instances in the "eu-west-2a" availability zone. 
# We're also using a "count" parameter to create 4 instances, and we're naming each instance using the "Name" tag with a unique index number.
#The "provisioner" block includes commands to install and start Apache on the instances using the remote-exec provisioner.


resource "aws_instance" "web_server_az1" {
  count = 2
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = "aws-key"
  vpc_security_group_ids = [aws_security_group.default.id]
  subnet_id = aws_subnet.web_server_subnet_1.id
  associate_public_ip_address = true
  provisioner "local-exec" {
    command = "printf '\n${self.public_ip}' >> aws_hosts && sleep 2m"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "sed -i '/^[0-9]/d' aws_hosts"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2",
      

    ]
  }
  

  tags = {
    Name = "web-server-${count.index+1}"
  }
}
