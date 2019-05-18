# DIGITA - make CI/CD easy
#### v1.0

# Оглавление

1. Введение
    - Зачем?
    - Выбор.
    - Общий план.
    - Приложение.
2. Global Requirements
3. Local Requirements
    - Linux Workstation
    - Git
    - Ansible
    - Openssl
    - GCP SDK (gcloud)
    - Jq
    - GCP Credentials
4. Подготовка
5. Cluster Install
6. Gitlab Install
7. Setup pipeline
8. Prometheus Install
9. Changelog


## 1. Introduce

 - ### Зачем? 
      - Для создания готового тестового стэнда для практического изучения [CI/CD](https://en.wikipedia.org/wiki/CI/CD "CI/CD").
      - Как проектная работа завершающая обучение в комапнии [OTUS](https://otus.ru/ "OTUS").
 - ### Выбор компонентов для построения системы CI/CD:
      - [GCP](https://cloud.google.com/ "GCP") - как платформа, есть опыт работы с данной платформой и ресурсы.
      - [Ansible](https://www.ansible.com/ "Ansible") - как система управления конфигурациями, широко распостраненная система.
      - [Nomad](https://www.nomadproject.io/ "Nomad HashiCorp") - как система оркестрации контейнеро, альтернатива K8S.
      - [Consul](https://www.consul.io/ "Consul HashiCorp") - как децентрализованный отказоустойчивый discovery-сервис, хорошая интеграция с Nomad и другими сервисами.
      - [Hashi-UI](https://github.com/jippi/hashi-ui "Hashi-UI") - как "современная" замена стандартному Web UI Nomad & Consul.
      - [Traefik](https://traefik.io/ "Traefik") - как Edge Router (reverse proxy / load balancer).
      - [GitLab CE](https://gitlab.com/gitlab-org/gitlab-ce/ "GitLab CE") - как современное популярное решение для управления разработкой программного обеспечения.
      - [Prometheus](https://prometheus.io/ "Prometheus") - как программный проект с открытым исходным кодом, написанный на Go, который используется для записи метрик в реальном времени в базе данных временных рядов.
      - [Grafana](https://grafana.com/ "Grafana") - как средство визуализации метрик из различных источников. "The open platform for beautiful analytics and monitoring".
      - Общий план нашего кластера:
 ![Cluster](/doc/digita-01.png)
 - ### Приложение, которое будет использоваться для тестирования системы.
     - Должно быть компактным, не монолитным. Желательно написаное на распостраненном языке програмирования. Без изысков работать в контейнере.
     - Выберем "Crawler":     
     https://github.com/express42/search_engine_crawler    
     https://github.com/express42/search_engine_ui    
     - схема работы и компонентов:
     ![crawler-review1](doc/crawler-review1.png)
     ![crawler-review2](doc/crawler-review2.png)
     - Исходники пришлось немного поправить для параметризации некоторых захардкоженных параметров (сервисы могут слушать на не стандартных портах).
         <details><summary>подробности</summary><p>

         ```bash
         diff crawler.origin.py crawler.py 
         44a45,46
         >             port=mqport,
         >             virtual_host=mqvhost,
         80a83,85
         > 
         > mqport = int(getenv('RMQ_PORT', '5672'))
         > mqvhost = getenv('RMQ_VHOST', '/')
         
         diff README.origin.md README.md 
         24a25,27
         > * `RMQ_PORT` - номер порта для подключения к `rabbitmq`
         > * `RMQ_VHOST` - виртуальный хост в `rabbitmq`
         ```

         </p></details>
         
## 2. Global Requirements
- GCP account https://cloud.google.com/ - Потребуется банковская/пластиковая карта для регистрации акаунта.
- В процессе работы потребуется виртуалки с общим обьемом памяти около 16-24Gb. Если отключить все сервисы по разработке, логированию и мониторинга, то потребуется около 4Gb RAM.
- Требования к дисковое пространству - около 30Gb на ноду.
- CPU - желательно по 2 ядра на ноду и выше. Для тестирования технологии можно обойтись и одним.
 
## 3. Local Requirements
- Linux Workstation (Ubuntu, Debian, CentOS ...)
- Git - https://github.com/git/git:
```bash
#Ubuntu, Debian
sudo apt update && sudo apt install git
git config --global user.name "Your Name"
git config --global user.email "youremail@domain.com"
git version
```
```bash
#CentOS, RHEL
sudo yum update && sudo yum install git
git config --global user.name "Your Name"
git config --global user.email "youremail@domain.com"
git version
```
 - Anible (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html):
```bash
#Ubuntu:
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible
```
```bash
#Debian
deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt-get update
sudo apt-get install ansible

```
```bash
#CentOS - RPMs for currently supported versions of RHEL, CentOS, and Fedora are available from EPEL as well as releases.ansible.com.
sudo yum install ansible

```
```bash
#(GCP) modules require both the requests and the google-auth libraries to be installed.
pip install requests google-auth apache-libcloud
```

 - OpenSSL
```bash
openssl version
```
 - GCP SDK (gcloud) https://cloud.google.com/sdk/install    
Quickstart for Linux - https://cloud.google.com/sdk/docs/quickstart-linux    
Debian/Ubuntu - https://cloud.google.com/sdk/docs/downloads-apt-get    
CentOS/RHEL - https://cloud.google.com/sdk/docs/downloads-yum   
 - Быстрый тест:
```bash
gcloud auth list

Credentialed Accounts
ACTIVE  ACCOUNT
*       youaccount@gmail.com

gcloud config list

[compute]
region = europe-west1
zone = europe-west1-b
[core]
account = youaccount@gmail.com
disable_usage_reporting = True
project = you_gcp_project
```
- Jq - https://github.com/stedolan/jq
```bash
wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O jq && chmod +x jq && mv jq /usr/local/bin

#In debian or ubuntu:
sudo apt install jq

#In centos or rhel whith EPEL repo on (yum install epel-release -y):
yum install jq -y

#Test:
jq --version

```
- GCP Credentials. Для совместной работы Ansible и GCP нужно предоставить полномочия Ansible:
    - Ссылка на документацию Ansible по этому вопросу - https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html
    - В итоге нужно получить полномочия в виде файла (в JSON формате) и скопировать его в домашний каталог пользователя, в директорию gcp (пример):
```bash
mkdir ~/gcp && cp ${where is service account json file} ~/gcp/infra.json
cat ~/gcp/infra.json 
{
  "type": "service_account",
  "project_id": "youprojectid",
  "private_key_id": "youprivatekeyid",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDbjs7xAJ3aubPK\naQdS2TREaIbWstPX+do/EJY=\n-----END PRIVATE KEY-----\n",
  "client_email": "824434134134112-compute@developer.gserviceaccount.com",
  "client_id": "108742520784583179674",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/87323425125-compute%40developer.gserviceaccount.com"
}

```
- Ansible Dynamic Inventory On Google Cloud:
```bash
cd /tmp && git clone https://github.com/ansible/ansible
cp /tmp/ansible/contrib/inventory/gce.ini ~/gcp/gce.ini
vim ~/gcp/gce.ini
###
###Edit/insert values into file:
#gce_service_account_email_address = you_email_address@developer.gserviceaccount.com 
#gce_service_account_pem_file_path = ~/gcp/infra.json
#gce_project_id = you_gcp_project
```
## 4. Подготовка
 - Склонируем репозитарий в домашнюю директорию:
 ```bash
 cd ~ && git clone https://github.com/sbelyanin/digita.git
 ```
 -  Сгенерируем локально ключи, сертификаты для CA, https и ssh при помощи ансибла: 
 ```bash
 cd ~/digita/ansible
 ansible-playbook playbooks/cert_key_make.yml
 
 #Cut output here
 #PLAY RECAP*********************************************************************************************************
 #localhost                  : ok=2    changed=2    unreachable=0    failed=0
 
 ls files/certs/*
 files/certs/CA.crt  files/certs/CA.srl        files/certs/registry.csr  files/certs/traefik.crt  files/certs/traefik.key
 files/certs/CA.key  files/certs/registry.crt  files/certs/registry.key  files/certs/traefik.csr
 
 cd ~/.ssh/ && ls ansible* developer*
 ansible  ansible.pub  developer  developer.pub
 ```

## 5. Cluster Install
 - Создание будущих нод кластера:
 ```bash
 cd ~/digita/ansible
 ansible-playbook playbooks/host-install.yml
 #Cut output here
 #PLAY RECAP *********************************************************************************************************
 #localhost                  : ok=5    changed=3    unreachable=0    failed=0   
 ```
 - Проверим работу dynamic inventory и доступность нод кластера:
```bash
cd ~/digita/ansible
./inventory.py --refresh-cache | jq
ansible -m ping tag_cluster-node
cluster-node-03 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
cluster-node-02 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
cluster-node-01 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```
 - Установим сертификаты и CA на все ноды:
 ```bash
 cd ~/digita/ansible
 ansible-playbook playbooks/cert_install.yml
 #Cut output here
 #PLAY RECAP *********************************************************************************************************
 #cluster-node-01            : ok=7    changed=6    unreachable=0    failed=0   
 #cluster-node-02            : ok=7    changed=6    unreachable=0    failed=0   
 #cluster-node-03            : ok=7    changed=6    unreachable=0    failed=0   
 ```
 - Установим docker на ноды:
 ```bash
 cd ~/digita/ansible
 ansible-playbook playbooks/docker_install.yml
 #Cut output here
 #PLAY RECAP *******************************************************************************************************
 #cluster-node-01            : ok=15   changed=7    unreachable=0    failed=0   
 #cluster-node-02            : ok=15   changed=7    unreachable=0    failed=0   
 #cluster-node-03            : ok=15   changed=7    unreachable=0    failed=0
 
 ```
 - Установим consul и nomad (основные компоненты кластера) на ноды:
 ```bash
 cd ~/digita/ansible
 ansible-playbook playbooks/consul_install.yml
 ansible-playbook playbooks/nomad_install.yml 
 ```
 Убедитесь что инсталяции consul и nomad прошли успешно, вывод работы ansible-playbook не должен содеpжать ошибки (failed=0):
 ```bash
 #Cut output here
 #PLAY RECAP *******************************************************************************************************
 #cluster-node-01            : ok=25   changed=19   unreachable=0    failed=0   
 #cluster-node-02            : ok=24   changed=19   unreachable=0    failed=0   
 #cluster-node-03            : ok=24   changed=19   unreachable=0    failed=0
 ```
 - Установим сервисы и системные компоненты для нашего кластера (системные компоненты будут запущены на каждой ноде). Traefik, Hashi-ui, registry, cadvisor, node-exporter и fluentd:
 ```bash
 cd ~/digita/ansible
 ansible-playbook playbooks/jobs_service_install.ym
 ```
 
 - Добавим резолвинг наших сервисов в локальный резолвинг через /etc/hosts используя публичный IP первой ноды:
 ```bash
 cd ~/digita/ansible
 export RESOLV=`./inventory.py --refresh-cache | jq -r '._meta.hostvars."cluster-node-01".gce_public_ip'`
 echo -e "$RESOLV gitlab hashi-ui rabbitmq crawler-master crawler-branch crawler prometheus grafana kibana\n" | sudo tee -a /etc/hosts
 ```
 - Зайдем на https://hashi-ui (сторонний web ui для Consul и Nomad) и проверим работу кластера. Т.к. наш сертификат самоподписанный в браузере придется подтвердить исключение безопасности:
  ![Hashi-ui](/doc/Nomad-Hashi-UI.png)
  
## 6. Gitlab Install
 - Все готово для инсталяции нашей системы разработки и поставки приложения.
 - Для разработки и тестирования приложения к Gitlabу нужен агент - раннер, он же в свою очередь должен зарегестрироватья в gitlab при помощи токена, который неизвестен и не задан (в текущей реализации проекта) на моменте инсталяции. Поэтому его нужно "узнать" после инсталяции gitlab и передать его в раннер при старте/регистрации. Для того чтобы ранер при старте "знал" токен воспользуемся KV хранилищем предоставляемым Consul сервисом. Также воспользуемся этим для хранения CA сертификата чтобы подключаться к докер репозитарию из раннера. Так как Nomad на текущий момент (v0.9) не умеет задавать очередность выполнения заданий (в роадмапе уже есть в v1.0) выполним задачу в несколько этапов.
 - Проинсталируем gitlab и gitlab-runner и задачу по получению токена одновремено, после этого перестартуем в нужном нам порядке из "hashi-ui":
  ```bash
  cd ~/digita/ansible
  ansible-playbook playbooks/jobs_gitlab_install.yml
  ```
  - Вернемся в "hashi-ui" и проверим что KV значения хранят нужные нам данные. Это "gitlab/runner_ca" и gitlab/runner_token":    
  Передем в настройки "Consul", зайдем в KV хранилише и посмотрим значения ключей в "gitlab" ветке:
  ![hashi-ui-consul-kv-gitlab](doc/hashi-ui-consul-kv-gitlab-all.png)
 
  - Если их нет, или остутствует один из них, нужно перезапустить задание отвечающее за наполнение данной ветки KV хранилища в нашем кластере: 
  ![hashi-ui-nomad-restart-gitlab-consul](doc/hashi-ui-nomad-restart-gitlab-consul-all.png)
  
  - Зайдем на http://gitlab/, введем пароль для административного пользователя root:
  ![gitlab-reg](doc/gitlab-reg.png)
  - Войдем под пользователем "root" с введеным ранее паролем в систему gitlab.
  - Создадим группу "crawler":
  ![gitlab-create-group](doc/gitlab-create-group.png)
  ![gitlab-create-group-done](doc/gitlab-create-group-done.png)
  - и в ней два проекта - "app" и "ui":
  ![gitlab-create-projects](doc/gitlab-create-projects.png)
  ![gitlab-create-project-app](doc/gitlab-create-project-app.png)
  ![gitlab-create-project-ui](doc/gitlab-create-project-ui.png)
  ![gitlab-create-projects-done](doc/gitlab-create-projects-done.png)
  
   - В проекте app будем размещаться тестовое приложение "crawler", а в ui - web интерфейс для просмотра результатов работы приложения.
  
  - Создадим пользователя "developer", дадим ему права "Owner" на ранее созданную группу "Crawler" и соответственно на все проекты и субпроекты в этой группе. Также добавим публичный ключ (созданный ранее на этапе подготовки создания кластера) для безопасного подключения к CVS проектов:
      - Создаем пользователя "developer":
      ![gitlab-create-new-user](doc/gitlab-create-new-user.png)
      ![gitlab-create-new-user-1](doc/gitlab-create-new-user-1.png)
      ![gitlab-create-new-user-2](doc/gitlab-create-new-user-2.png)
      ![gitlab-create-new-user-3](doc/gitlab-create-new-user-3.png)
      ![gitlab-create-new-user-impersonate](doc/gitlab-create-new-user-impersonate.png)
      ![gitlab-create-new-user-profile](doc/gitlab-create-new-user-profile.png)
      ![gitlab-create-new-user-pkey](doc/gitlab-create-new-user-pkey.png)
      ![gitlab-create-new-user-done](doc/gitlab-create-new-user-donw.png)
  
  - Проверим наличие зарегестрированного ранера в GitLab. Зайдем в "Admin Area", "Runners" и проверим:
      - Если в наличии у нас нету раннеров:
      ![gitlab-runnner-absent](doc/gitlab-runnner-absent.png)
      - переходим на "hashi-ui" в управление джобами и рестартуем "runner-job":
      ![gitlab-runnner-restart-1](doc/gitlab-runnner-restart-1.png)
      ![gitlab-runnner-restart-2](doc/gitlab-runnner-restart-2.png)
      - после перезапуска джоба раннер должен появиться в списке: 
      ![gitlab-runnner-present](doc/gitlab-runnner-present.png)
      - Ранеры "одноразовые/стайтлэс" - поэтому список может содержать не действительные экзэмпляры и этот список нужно/можно чистить. Количество ранеров можно задавать при старте или при реконфигурировании.
      
## 7. Setup pipeline
 - Приступим к наполнению наших проектов. Для удобства "общения" с нашими репозиториями воспользуемся услугами ssh и ранее созданной пары ключей:
```bash
>> ~/.ssh/config && chmod 600 ~/.ssh/config
vim ~/.ssh/config
##Insert:
#Host            gitlab
#HostName        gitlab
#Port            1022
#User            developer
#IdentityFile    ~/.ssh/developer
```
  - Зальем содержимое директорий "digita/crawler/app" и "digita/crawler/ui" в наши репозитории GitLab:
      - "app". Найдем ссылку на репозиторий в gitlab:
      ![gitlab-repo-app](doc/gitlab-repo-app.png)
      - "ui":
      ![gitlab-repo-ui](doc/gitlab-repo-ui.png)
      - Проинициализируем директории с исходниками и зальем их в репозитарии gitlab:
      ```bash
      ###APP###
      cd crawler/app && git init
      git remote add origin git@gitlab:crawler/app.git
      git add .
      git commit -m "Initial commit"
      git push -u origin master
      ###UI###
      cd crawler/ui && git init
      git remote add origin git@gitlab:crawler/ui.git
      git add .
      git commit -m "Initial commit"
      git push -u origin master
      ```
      - Проверим что наш "pipeline" готов к работе на примере основного приложения "app". Зайдемм в UI GitLab и перейдем по ссылкам "Projects", "crawler/app", "CI/CD":
      ![gitlab-pipeline-app](doc/gitlab-pipeline-app.png)
      видим что первая задача в пайплайне (тестирование кода) выполнено и дальнейшие шаги нужно запускать в ручную (данное поведение настраивается в .gitlab-ci.yml). Посмотрим что же можно слелать дальше:
![gitlab-pipeline-app-all](doc/gitlab-pipeline-app-all.png)
 - На изображении представлен пайплайнм мастер ветки нашего приложения.     
 Он состоит из 5 этапов (обведены красным):
     - "Test" - (1) Запускается сразу при очередном коммите в мастер ветке. Производят тесты с исходным кодом.
     - "Build" - (2, 3) Запускаются в ручную. 2 задача "Build master" - создание и публикация в локальном регистри докер образа "crawler_app:master" с приложением. 3 задача "recreate-mongodb-master" - запуск/перезапуск stateless ДБ mongodb для мастер релиза приложения (nomad job - mongodb-master-job).
     - "Review" - (4, 5, 6) Запускаются в ручную. 4 задача "run-review-master" - запуск/перезапуск докер имиджа "crawler_app:master" через job nomad. 5 и 6 задача - останавливают мастер релиз приложения и базу для него. Для уборки в "доме".
     - "Build-release" (7). Запускаются в ручную. 7 задача - "build-release" - создание и публикация в локальном регистри докер образа "crawler_app:release" с релизом приложения.
     - "Deploy-release"(8). Запускаются в ручную. 8 задача - "deploy-release" - деплой приложения в продакщен, запуск/перезапуск докер имиджа "crawler_app:release" через job nomad.
 
 - Создадим ветку "develop" от мастера и посмотрим какой пайплайн получиться:
 ![gitlab-pipeline-app-branch-all](doc/gitlab-pipeline-app-branch-all.png)
 Здесь все задачи по созданию, публикации и запуска докер образа "crawler_app:branch" запускаются последовательно и автоматически при появлении изменений в branch ветки приложения. Также присутствуют задачи по запуску/остановки stateless ДБ mongodb для branch релиза приложения (nomad job - mongodb-branch-job). Дополнительно можно остановить БД и приложение branch ветки. 
 
 - Посмотрим каков пайплайн для Web UI приложения:
 ![gitlab-pipeline-ui-all](doc/gitlab-pipeline-ui-all.png)
 - Отличия от самого приложения "crawler" в паплайне "UI" минимальны - работа в мастер ветке ведется с докер образами "crawler_ui:master" и "crawler_ui:release", а в branch ветках - "crawler_ui:branch". Также при выполнении этапов "Review" и "Deploy-release" Web UI будет доступен по ссылкам https://crawler/ , https://crawler-master/ , https://crawler-branch/.
 - Взглянем на текущее количество задач которое обслуживает наш кластер:
 ![Nomad-Jobs-All](doc/Nomad-Jobs-All.png)
      
## 7. Prometheus setup
 - Приступим к мониторингу, установим Prometheus и Grafana:
 ```bash
 cd ~/digita/ansible
 ansible-playbook playbooks/jobs_gitlab_install.yml
 ```
 - После инсталяции зайдем на https://prometheus/targets и убедимся что все наши таргеты подняты:
 ![prometheus-target-all](doc/prometheus-target-all.png)
 - Посмотрим состояние Grafana, зайдем на https://grafana/ (admin/GraFanA):
 ![grafana-welcome](doc/grafana-welcome.png)
 - Импортируем дашбоард для нашего приложения и дашбоард "Node Exporter Full(1860)". Перейдем на страницу импорта дашбоардов в графане:
 ![grafana-import-dashboard](doc/grafana-import-dashboard.png)
 Загрузим из "ansible/files/grafana" дашбоарды "crawler-v*" и "1860".
 - для мониторинга хостовых систем метрик от "node-exporter" будет предостаточно:
 ![grafana-dashboard-1860](doc/grafana-dashboard-1860.png)
 - для мониторинга приложения "crawler" будем использовать метрики от самого приложения через дашбоард "crawler":
 ![grafana-dashboard-crawler](doc/grafana-dashboard-crawler.png) 
 - для тестирования новой возможности по провижиненгу дашбоардов и датасоурсов были опробованны: датасоурс - prometheus и дашбоард "Docker and Host Monitoring w/ Prometheus". (Мы ведь их не настраивали при инсталяции?):
     - ![grafana-dashboard-docker-host](doc/grafana-dashboard-docker-host.png) 
     - ![grafana-ds-prometheus](doc/grafana-ds-prometheus.png) 

## 9. Changelog
 - v1.0 Создание документации.
 - v0.9 Создание PipeLine для приложения.
 - v0.8 Добавление установки efk на кластер. Первоначальная настройка.
 - v0.7 Добавление установки Prometheus на кластер. Настройка экспортеров. Добавление Grafana. Создание кастомного дашбоарда для приложения "crawler".
 - v0.6 Добавление установки gitlab ce на кластер. Настройка gitlab runner.
 - v0.5 Внедрение hashi-ui. Перенос UI consul и nomad в hasi-ui. 
 - v0.4 Настройка создание self signet certs и работоспособность docker registry с ними.
 - v0.3 Тестирование fabio, nginx и traefik в качестве edge router - выбран traefik.
 - v0.2 Изменение в кодовой базе ролей инсталяции consul и nomad. Изменение поределение ролей нод в кластере при использовании dynamic inventory.
 - v0.1 Создание ansinle playbook для инсталяции хостов кластера и наливки docker, nomad и consul на них. Для consul и nomad были выбраны роли из галакси - https://galaxy.ansible.com/brianshumate/consul/ и https://galaxy.ansible.com/brianshumate/nomad. 
 Для накатки докера простенький - https://galaxy.ansible.com/geerlingguy/docker
