## 打包的脚本（只展示必要步骤）
#!/usr/bin/env bash

## 接受 ENV
env=$1

## 这里可以区分开发和线上的不同env配置文件，一般是请求的资源和API的url不同
if [ $env = "pre" ];then
    cp .env_pre .env
elif [ $env = "prod" ];then
    cp .env_prod .env
else
    exit 1
fi

# yarn打包
yarn build

# 打包docker镜像

time=$(date "+%Y%m%d%H%M%S")
tag="$time"

app_name=ops"_""$env"
default_registry=https://github.com/hugc/vue3-docker-demo.git
default_project=ops
default_user=540319496@qq.com
default_pwd=hz2903HZC
dockerfile=Dockerfile
nginx_conf="./scripts/nginx_""$env"".conf"

echo $(date "+%Y-%m-%d %H:%M:%S")-开始制作镜像
docker build --platform linux/amd64 --rm --build-arg NGINX_CONF=$nginx_conf -t $app_name:latest . 
echo $(date "+%Y-%m-%d %H:%M:%S")-镜像制作完成

echo $(date "+%Y-%m-%d %H:%M:%S")-开始打tag
docker tag $app_name:latest $default_registry/$default_project/$app_name\:$tag
echo $(date "+%Y-%m-%d %H:%M:%S")-打tag完成

echo $(date "+%Y-%m-%d %H:%M:%S")-开始push镜像
docker login -u $default_user -p $default_pwd $default_registry
docker push $default_registry/$default_project/$app_name\:$tag
echo $(date "+%Y-%m-%d %H:%M:%S")-push镜像完成

echo $(date "+%Y-%m-%d %H:%M:%S")-删除本地镜像
docker rmi $app_name\:latest
docker rmi $default_registry/$default_project/$app_name\:$tag

echo "执行发布脚本请输入tag："
echo $tag