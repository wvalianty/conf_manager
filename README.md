# 配置文件管理
使用 gitlab 管理配置文件，gitlab 触发拉取仓库中的配置文件，生成对比结果。

![eye_index.jpeg](https://raw.githubusercontent.com/wvalianty/conf_manager/main/screenshots/eye_index.jpeg)
![diff_example.png](https://raw.githubusercontent.com/wvalianty/conf_manager/main/screenshots/diff_example.png)

## 起因
* 上百上千 nginx 实例怎么维护？配置文件肯定不再手动一台一台修改，怎么实现批量修改？
- 在修改线上环境之前，是否可以自动化测试测试环境，测试好之后自动同步到线上？  
* 公司服务很多，配置文件也很多，怎么及时发现配置文件被人修改？ 

## 运行流程
![work_process.png](https://raw.githubusercontent.com/wvalianty/conf_manager/main/screenshots/work_process.png)

## gitlab 配置
* git 仓库修改，触发 webhook 自动拉取，重新生成对比结果。  
![gitlab_index.png](https://raw.githubusercontent.com/wvalianty/conf_manager/main/screenshots/gitlab_index.png)
![gitlab_webhook_config.png](https://raw.githubusercontent.com/wvalianty/conf_manager/main/screenshots/gitlab_webhook_config.png)

## 后续计划
* 代码优化，python 多线程生成目标文件
* webhook 被触发和执行 pull 进行结偶，加入一个 MQ
* 文件对比忽略项
* 。。。