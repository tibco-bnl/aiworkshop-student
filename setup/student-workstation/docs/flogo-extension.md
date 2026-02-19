## Flogo extensions 

Several flogo activity extensions are used in this workshop.<br>
These exensions are maintained in seperate git repos. <br>

VS-Code on the student worksation is configured to import extension from the directory specified in the Flogo setting 'Extensions: Local'<br>

### synching extensions
A bash script named 'sync-flogo-extensions.sh' automates updating the flogo extension on the student workstation. 
It will:
* pull the latest changes from the present git repos into the base git directory
* create a timestamped backup of existing extensions in the local extension directory
* copy the changes in git directories into the local extension. rsync is used to sync the directory, meaning not only copying updates and new files but also removing files and not copying any .git files.
* before performing the backup and sync, the source and target directories are compared (rsync dry-run) to check if changes occured.
* using --force flag will skip the comparison 

Once the sync has been performed any vs code istance need to be restartup to pick up changes.

### directories

The following directories are used:

* scripts: /workshop/scripts
* git sources: /workshop/git
* flogo local extensions: /workshop/vscode/extensions/flogo-extensions
* backups: /workshop/backups