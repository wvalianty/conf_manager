## 配置文件管理

### 起因
>之前曾经就职一家规模比较大的公司，nginx 实例上百，为了维护和审计，公司开发了多个平台。  

>>nginx 配置文件检查平台，领导开会，通过这个平台查看 nginx 都有什么修改。

>>有 nginx 配置管理平台，可以通过表单批量修改 nginx 配置。

这里我想通过 git 仓库管理配置文件，目标是管理所有服务都配置文件，可以实现通过提交修改到 git 仓库，触发自动推送到测试机器，然后合并到主干分支的时候自动同步到线上。

本地会定期服务器上的配置文件到本地，在有新修改提交到 git 仓库的时候，会触发 webhook 拉取新的配置，重新生成对比结果页面。

### 当前状态
* git 仓库修改，触发 webhook 自动拉取，重新生成对比结果。
![gitlab_index.png](https://raw.githubusercontent.com/wvalianty/conf_manager/main/screenshots/gitlab_index.png)

![gitlab_webhook_config.png](https://raw.githubusercontent.com/wvalianty/conf_manager/main/screenshots/gitlab_webhook_config.png)

![eye_index.jpeg](https://raw.githubusercontent.com/wvalianty/conf_manager/main/screenshots/eye_index.jpeg)

![diff_example.png](https://raw.githubusercontent.com/wvalianty/conf_manager/main/screenshots/diff_example.png)
![file_show.png](https://raw.githubusercontent.com/wvalianty/conf_manager/main/screenshots/file_show.png)
### 存在问题
webhook 触发处理是同步的，打算使用猴子补丁改造成异步。
### 愿景
可以管理所有服务的配置文件，从测试到生产。
