let

  region = "us-east-1";
  accessKeyId = "default"; # symbolic name looked up in ~/.ec2-keys or a ~/.aws/credentials profile name
  credentials = { inherit region accessKeyId; };

  ec2 =
    { resources, ... }:
    { deployment.targetEnv = "ec2";
      deployment.ec2.accessKeyId = accessKeyId;
      deployment.ec2.region = region;
      deployment.ec2.ami = "ami-0f8b063ac3f2d9645"; # Make sure we have the right version of NixOS.
      deployment.ec2.instanceType = "t3.micro";
      deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
      # Allow HTTP/HTTPS and SSH access
      deployment.ec2.securityGroups = [
        "HTTP/HTTPS"
        "ssh"
      ];
      # Give some space to store uploads
      deployment.ec2.blockDeviceMapping."/dev/nvme1n1" = {
        size = 2;
        iops = 0;
        volumeType = "gp2";
      };
      fileSystems."/tmp/photostrip" = {
        device = "/dev/nvme1n1";
        autoFormat = true;
        fsType = "ext4";
      };
      # Add some swap space to buffer the lower memory of t3.micro
      deployment.ec2.blockDeviceMapping."/dev/nvme2n1" = {
        size = 2;
        iops = 0;
        volumeType = "gp2";
      };
      swapDevices = [{
        device = "/dev/nvme2n1";
      }];
      # Set up DNS for this ec2 instance
      deployment.route53 = {
        accessKeyId = accessKeyId;
        hostName = "photostrip.danielwilsonthomas.com";
      };
      # Import the service config
      imports = [ ./photostrip-service.nix ];

    };

in
{
  photostrip = ec2;

  # VM for testing why the service dies on EC2
  photostrip-vm = { ... }: {
    deployment.targetEnv = "virtualbox";
    deployment.hasFastConnection = true;
    deployment.virtualbox.memorySize = 512; # megabytes
    deployment.virtualbox.headless = true;
    deployment.virtualbox.vcpu = 1; # number of cpus
    deployment.virtualbox.disks = { big-disk = { port = 1; size = 4096; }; };
    imports = [ ./photostrip-service.nix ];
    swapDevices = [];
  };

  # Provision an EC2 key pair.
  resources.ec2KeyPairs.my-key-pair =
    { inherit region accessKeyId; };
}
