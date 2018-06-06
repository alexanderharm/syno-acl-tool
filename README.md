# Syno ACL Tool

This script applies ACLs from a list to specified dirs.

#### 1. Notes

- The script is able to automatically update itself using `git`.

#### 2. Installation

##### 2.1 Install Git (optional)

- install the package `Git Server` on your Synology NAS, make sure it is running (requires sometimes extra action in `Package Center` and `SSH` running)
- alternatively add SynoCommunity to `Package Center` and install the `Git` package ([https://synocommunity.com/](https://synocommunity.com/#easy-install))
- you can also use `entware-ng` (<https://github.com/Entware/Entware-ng>)

##### 2.2 Install this script (using git)

- create a shared folder e. g. `sysadmin` (you want to restrict access to administrators and hide it in the network)
- connect via `ssh` to the NAS and execute the following commands

```bash
# navigate to the shared folder
cd /volume1/sysadmin
# clone the following repo
git clone https://github.com/alexanderharm/syno-acl-tool
# to enable autoupdate
touch syno-acl-tool/autoupdate
```

##### 2.3 Install this script (manually)

- create a shared folder e. g. `sysadmin` (you want to restrict access to administrators and hide it in the network)
- copy your `synoAclTool.sh` to `sysadmin` using e. g. `File Station` or `scp`
- make the script executable by connecting via `ssh` to the NAS and executing the following command

```bash
chmod 755 /volume1/sysadmin/synoAclTool.sh
```

#### 3. Setup

- run script manually after edits to your ACL list

```bash
sudo /volume1/sysadmin/syno-acl-tool/synoAclTool.sh "/path/to/acls"
```

*AND/OR*

- create a task in the `Task Scheduler` via WebGUI

```
# Type
Scheduled task > User-defined script

# General
Task:    SynoAclTool
User:    root
Enabled: yes (untick if you only want to run manually via WebGUI)

# Schedule
Run on the following days: Daily
First run time:            00:00
Frequency:                 once a day
Last run time:			   00:00

# Task Settings
User-defined script: /volume1/sysadmin/syno-acl-tool/synoAclTool.sh "/path/to/acls"
```

#### 4. Format

You can pass a list of ACLs in the following format:

```
<path1>;<user|group>:<name1>:[<r|w|rw>],<user|group>:<name2>:[<r|w|rw>],...
<path2>;<user|group>:<name3>:[<r|w|rw>],<user|group>:<name4>:[<r|w|rw>],...
```

- `path`: absolute path to a directory
- `type`: you must specify if ACL applies to `user` or `group`
- `name`: enter a user or group name
- `permission`: optional (defaults to `rw`), possible values are `r`, `w`, `rw`

Examples:

```
/volume1/SharedFolder1/parentdir/dir;user:johndoe:r,user:janedoe
# resulting ACLs:
# ACLs inherited from /volume1/SharedFolder1/parentdir
# + read permissions for user johndoe
# + read/write permissions for user janedoe

/volume1/SharedFolder1/another/parentdir/dir;group:office:w
# resulting ACLs:
# ACLs inherited from /volume1/SharedFolder1/another/parentdir
# + write permissions for group office
```