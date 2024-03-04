# MihoyoBBSTools_Feishu

此项目基于[Womsxd/MihoyoBBSTools](https://github.com/Womsxd/MihoyoBBSTools)，在此基础之上增加了飞书推送签名校验、自动编译部署(仅支持Linux)

## 如何使用程序

### 环境要求

- Python (>3.0)，pip
- Dart SDK (>=3.0.0)
- Git

> Dart SDK 安装教程参考[Get the Dart SDK](https://dart.dev/get-dart)

### 1. 使用Git克隆本项目到本地

```
git clone https://github.com/patryyyy/MihoyoBBSTools_Feishu.git
```

### 2. 构建 

请确保你在项目的根目录下，然后运行`build.sh`

```
chmod +x ./build.sh
./build.sh
```

### 3. 配置config.yaml

1. 打开目录中的**config 文件夹**复制`config.yaml.example`并改名为`config.yaml`，脚本的多用户功能靠读取不同的配置文件实现，你可以创建无数个`自定义名字.yaml`，脚本会扫描**config**目录下`yaml`为拓展名的文件，并按照名称顺序依次执行。

2. 请使用 vscode/vim等文本编辑器打开上一步复制好的配置文件

3. **使用[获取 Cookie](#获取米游社-cookie)里面的方法来获取米游社 Cookie**

4. 将复制的 Cookie 粘贴到`config.yaml`的`cookie:" "`中(在`account`里面)

    例子

    > ```yaml
    > cookie: 你复制的cookie
    > ```

5. **使用[获取设备 UA](#获取设备 UA)里面的方法来获取 UA**

6. 将复制的 UA 粘贴到`config.yaml`的`useragent:" "`中(在`games`里面)

    例子

    > ```yaml
    > useragent: 你复制的UA
    > ```

    **配置签到用的ua 脚本会在后面自动加上miHoYoBBS/版本号 ,请复制的时候不要带miHoYoBBS/版本**

7. 检查`config.yaml`的`enable:`的值为 true

### 4. 启动服务

使用以下命令以启动`start_mihoyo_bbs_tools`服务

```
sudo systemctl start start_mihoyo_bbs_tools
```

> **该服务将会在每天9:00 + (1 ~ 10800)s定时签到**

## 获取米游社 Cookie

1. 打开你的浏览器,进入**无痕/隐身模式**

2. 由于米哈游修改了 bbs 可以获取的 Cookie，导致一次获取的 Cookie 缺失，所以需要增加步骤

3. 打开`https://www.miyoushe.com/ys/`并进行登入操作

4. 按下键盘上的`F12`或右键检查,打开开发者工具,点击`Source`或`源代码`

5. 键盘按下`Ctrl+F8`或点击停用断点按钮，点击` ▌▶`解除暂停

6. 点击`NetWork`或`网络`，在`Filter`或`筛选器`里粘贴 `getUserGameUnreadCount`，同时选择`Fetch/XHR`

7. 点击一条捕获到的结果，往下拉，找到`Cookie:`

8. 从`cookie_token_v2`开始复制到结尾

   ```text
   示例:
   cookie_token_v2=xxx; account_mid_v2=xxx; ltoken_v2=xxx; ltmid_v2=xxx;
   ```

9. 将此处的复制到的 Cookie 先粘贴到 config 文件的 Cookie 处，如果末尾没有`;空格`请手动补上

10. 打开`http://user.mihoyo.com/`并进行登入操作

11. 按下键盘上的`F12`或右键检查,打开开发者工具,点击 Console

12. 输入

```javascript
var cookie=document.cookie;var ask=confirm('Cookie:'+cookie+'\n\nDo you want to copy the cookie to the clipboard?');if(ask==true){copy(cookie);msg=cookie}else{msg='Cancel'}
```

回车执行，并在确认无误后点击确定。

13. 将本次获取到的 Cookie 粘贴到之前获取到的 Cookie 后面

14. **此时 Cookie 已经获取完毕了**

## 海外版获取Cookie

1. 打开你的浏览器,进入**无痕/隐身模式**

2. 打开`https://act.hoyolab.com/bbs/event/signin/hkrpg/index.html?act_id=e202303301540311`并进行登入操作

3. 按下键盘上的`F12`或右键检查,打开开发者工具,在控制台输入:

    ```javascript
    document.cookie
    ```

4. 从`ltoken=....`开始复制到结尾

5. 将获取到的 Cookie 粘贴到之前获取到 OS 的 Cookie 里面

## 获取设备 UA

1. 使用常用的移动端设备访问 `https://www.ip138.com/useragent/`

2. 复制网页内容中的 `客户端获取的UserAgent`

3. 替换配置文件中 `useragent` 的原始内容

## 获取云原神的 token

1. 建议使用打开浏览器的无痕/隐私/InPrivate模式

2. 打开 [云原神网页版](https://ys.mihoyo.com/cloud/#/)

3. 按下键盘上的`F12`或右键检查,打开开发者工具,在打开后登入账号

4. 在filter里面输入`wallet/wallet/get`,选择`status`为`200`的记录

5. 点击记录，往下拉，找到`X-Rpc-Combo_token`,复制对应的值,成功获取token

## 使用的第三方库

Python:

- ~~requests~~: [GitHub](https://github.com/psf/requests) [pypi](https://pypi.org/project/requests/)

- requests仅作为在httpx无法使用时的备用选择，可能未来版本会进行移除

- httpx: [GitHub](https://github.com/encode/httpx) [pypi](https://pypi.org/project/httpx/)

- crontab: [GitHub](https://github.com/josiahcarlson/parse-crontab) [pypi](https://pypi.org/project/crontab/)

- PyYAML: [GitHub](https://github.com/yaml/pyyaml) [pypi](https://pypi.org/project/PyYAML/)

Dart:

1. build_mihoyo_bbs_tools
   - [logger](https://pub.dev/packages/logger)
   - [path](https://pub.dev/packages/path)
   - [system](https://pub.dev/packages/system)
   - [lints](https://pub.dev/packages/lints)
2. feishu_push
   - [args](https://pub.dev/packages/args)
   - [crypto](https://pub.dev/packages/crypto)
   - [dio](https://pub.dev/packages/dio)
   - [lints](https://pub.dev/packages/lints)
3. start_mihoyo_bbs_tools
   - [cron](https://pub.dev/packages/cron)
   - [path](https://pub.dev/packages/path)
   - [lints](https://pub.dev/packages/lints)

## 关于使用 Github Actions 运行

本项目**不支持**也**不推荐**使用`Github Actions`来每日自动执行！

也**不会**处理使用`Github Actions`执行有关的 issues！

## License

[**本仓库License**](https://github.com/patryyyy/MihoyoBBSTools_Feishu/blob/master/LICENSE)

[**原作者License**](https://github.com/patryyyy/MihoyoBBSTools_Feishu/blob/master/LICENSE-Womsxd)

## 鸣谢

[JetBrains](https://jb.gg/OpenSource)

[Womsxd/MihoyoBBSTools](https://github.com/Womsxd/MihoyoBBSTools)

[XiaoMiku01/miyoubiAuto](https://github.com/XiaoMiku01/miyoubiAuto)

[本项目的Contributors](https://github.com/patryyyy/MihoyoBBSTools_Feishu/graphs/contributors)

还有正在使用这份程序的你

> 本文档参考了原作者的README.md
