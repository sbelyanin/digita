# DIGITA - make CI/CD easy

## Introduce

 - Зачем? 
  - Для создания готовго тестового стэнда для практического изучения CI/CD.
  - Как проектная работа завершающая обучение в компнии OTUS.
 - Выбор компонентов для построения системы CI/CD:
  - GCP как платформа- есть опыт работы с данной платформой и ресурсы.
  - Ansible как система управления конфигурациями - широко распостраненная система.
  - Nomad HashiCorp как система оркестрации контейнеров - как альтернатива K8S.
  - Consul HashiCorp децентрализованный отказоустойчивый discovery-сервис - хорошая интеграция с Nomad и другими сервисами.
  - GitLab CE - современное популярное решение для управления разработкой программного обеспечения.
  - Prometheus - рограммный проект с открытым исходным кодом, написанный на Go, который используется для записи метрик в реальном времени в базе данных временных рядов.
  
  
 - Общий план нашего кластера:
 ![Cluster](/doc/digita-01.png)

### For first release

 - Install Nomad cluster whith Consul integration.
 - Install custom GitLab CI/CD
 - Assign dev, stage and prod environment
 - Install Prometheus, EFK

## Global Requrenments

 - GCP account https://cloud.google.com/ - Потребуется Банковская карта для регистрации акаунта.
 
## Local Requrenments
 
 - Linux Workstation (Ubuntu, Debian, CentOS)
 - Git:
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
pip install requests google-auth
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
project = youproject
```
- GCP Credentials. Для совместной работы Ansible и GCP нужно предоставить полномочия Ansible:
  - Ссылка на документацию Ansible по этому вопросу - https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html
  - В итоге нужно получить полномочия в виде файла в JSON формате и скопировать его в домашний каталог пользователя, в диреторию gcp (пример):
  ```bash
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

## Prepare

 - Clone this repository- 
 - Test for compatible local requirements.
 - Run 
   ssh-keygen -t rsa -f ~/.ssh/developer -C developer -P ""
   ssh-keygen -t rsa -f ~/.ssh/ansible -C ansible -P ""

## Install

 - Run ansible-playbook playbooks/host-install.yml
 - Run ./inventory.py --refresh-cache
 - Run ansible-playbook playbooks/cert-make.yml
 - Run ansible-playbook playbooks/cert-install.yml
 - Run ansible-playbook playbooks/consul-install.yml
 - Run ansible-playbook playbooks/docker-install.yml
