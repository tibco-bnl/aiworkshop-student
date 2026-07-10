# Student workstation introduction

The student workstation is a developer environment for students to execute the labs in this workshop.
It offers a flogo development environment where all the requirements are in place.

* MS Visual Code
* TIBCO Flogo visual code extension
* Several custom flogo activities
* Connectivity to other components

The student workstation is a multi user (student) environement based on a linux (Ubuntu) distribution hosten in the Azure cloud. It is accessable via the Remote Desktop Protocol (RDS).

In order to allow access the host of the workshop will allow connectivity and access to the student account.
<br>

- *** todo: image of components in workstation

# Access to workstation

## RDP access

Access to the workstation of provided via a RDS connection for this.
Follow below steps to setup a RDS connection

### Windows

1. Open the Remote destop client
[window] --> RDS --> Open
![alt text](/student/images/rds_connection.png)

2. Enter the hostname or ip address provided by the teacher in the 'Computer' field
3. Click 'Connect'
<br><br>
   
   ![alt text](/student/images/rds_secure.png)

4. Click 'Yes' to allow the remote connection
   <br><br><br>
![alt text](/student/images/rds_login.png)

5. Enter the workstation 'username' and 'password' provided by the teacher.
<br> You will now be logged into the workstation desktop
<br><br>![alt text](/student/images/rds_desktop.png)


This is a standard Ubuntu 24 Gnome desktop environment.

At the bottom of the screen the launch pad is showing the applications needed for the workshop.





## Remote Desktop tips and tricks

### Display resolution
The size of the RDS display is based on a setting in the RDS client.
This can be change by:
* On the RDS connect screen click 'Show Options'
* Open the 'display' tab.
 
Here the size of the display can be changed.

![alt text](/student/images/rds_display.png)

### Store username / password
To store the username and password in the RDS Client.
* On the RDS connect screen click 'Show Options'
* On the General tab enter 'Username' and check 'Allow me to save credentials'
![alt text](/student/images/rds_saveuser.png)