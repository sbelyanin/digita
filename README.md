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

## Requrements

 - GCP account
 - GCP SDK (gcloud), Ansible 

## Prepare

 - Clone this repository.
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
