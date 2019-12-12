# Core util Dockerfile
These images are used to help mailman core service to setup the basic domain&list and replace
default templates with the file located in repo's `templates` folder.

There are two different docker images are used here:
1. git-tools: This image used to clone the infrastructure repo from gitee and move templates folder
   to the core utils image working folder, please check the dockerfile `Dockerfile.git_tool`

2. core-utils: This image used to setting up the basic domain&lists and replace templates for mailman core service,
   please check the dockerfile `Dockerfile`.

