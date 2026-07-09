
# Student Workstation Installation and setup #

## Hosting

The student workstation desktop is hosted on a virtual machine in the Microsoft Azure environment. Rationale to use Azure is an simplified networking setup to allow the VM to access pods within an AKS hosted kubernetes cluster. Other components in the AIWorkshop architecture are hosted in this AKS cluster.

## Virtual machine
The virtual machine uses Linux distribution Ubuntu 24.04 pro version to allow desktop access.
The required base software is installed using Hashicorp Packer to automate installation. Please find details of the use of this [packer-setup.md](docs/packer-setup.md).

### Add participant IP addresses to Azure NSG
To allow participant access, update the source IP list in the Azure Network Security Group rule.

1. Open the Azure portal.
2. Search for `network security group`.
3. Open `NL-AI-Workshop-Desktop-nsg`.
4. Go to **Settings** > **Inbound security rules**.
5. Filter for rule `WorkshopParticipants`.
6. Edit the rule and update **Source** with the participant IP addresses.
7. Use a comma-separated list for multiple IP addresses.



## User setup
To enable multiple workshop attendees to use a virtual workstation multiple users will be created based on one template user.
<br>The procedure to update and clone the template user is described in document [user-cloning.md](docs/user-cloning.md).<br>
The principle behind the template user is to have one linux user which is never used during workshops but is the blueprint for workshops. <br>
During a new workshop preparation sufficient users are clone this the particular workshop. After completion of the workship these users will be deleted.

## Flogo extensions
Flogo extension needed for the workshop and description how to synchronize them described in document [flogo-extensions.md](docs/flogo-extension.md)