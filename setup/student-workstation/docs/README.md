# Student Workstation Installation and setup #

## Hosting

The student workstation desktop will be hosted on a virtual machine in the Microsoft Azure environment. Rationale to use Azure is an simplified networking setup to allow the VM to access pods within an AKS hosted kubernetes cluster. Other components in the AIWorkshop architecture are hosted in this AKS cluster.

## Virtual machine
The virtual machine uses Linux distribution Ubuntu 24.04 pro version to allow desktop access.
The required base software is installed using Hashicorp Packer to automate installation. Please find details of the use of this [packer-setup.md](packer-setup.md).



## User setup
To enable multiple workshop attendees to use a virtual workstation multiple users will be created based on one template user.
<br>The procedure to update and clone the template user is described in document [user-cloning.md](user-cloning.md).<br>
The principle behind the template user is to have one linux user which is never used during workshops but is the blueprint for workshops. <br>
During a new workshop preparation sufficient users are clone this the particular workshop. After completion of the workship these users will be deleted.
