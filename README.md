# DIGITA - make CI/CD easy

## Introduce
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
