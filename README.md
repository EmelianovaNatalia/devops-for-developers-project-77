### Hexlet tests and linter status:
[![Actions Status](https://github.com/EmelianovaNatalia/devops-for-developers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/EmelianovaNatalia/devops-for-developers-project-77/actions)

Проект полностью воспроизводим. Всё что нужно - аккаунт в Yandex Cloud.

### 1. Подготовка

```bash
# Клонировать репозиторий
git clone https://github.com/EmelianovaNatalia/devops-for-developers-project-77.git
cd devops-for-developers-project-77
2. Получить данные Yandex Cloud

Зарегистрироваться на https://cloud.yandex.ru
Получить OAuth токен: https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb
Скопировать cloud_id и folder_id из консоли
3. Создать файл с переменными

bash
cat > terraform/terraform.tfvars << EOF
yc_token     = "ваш_oauth_токен"
yc_cloud_id  = "ваш_cloud_id"
yc_folder_id = "ваш_folder_id"
EOF
4. Создать инфраструктуру

bash
cd terraform
terraform init
terraform apply -auto-approve
Будут созданы:

2 виртуальные машины (веб-серверы)
Балансировщик нагрузки
Сеть и подсеть
5. Получить IP адреса

bash
terraform output
Вывод:

text
vm1_ip = "публичный_ip"
vm2_ip = "публичный_ip"  
lb_ip  = "публичный_ip"
6. Обновить inventory

Отредактировать ansible/inventory.ini, подставить полученные IP:

ini
[webservers]
vm1 ansible_host=ПОДСТАВИТЬ_IP_VM1 ansible_user=ubuntu
vm2 ansible_host=ПОДСТАВИТЬ_IP_VM2 ansible_user=ubuntu

[loadbalancer]
vm3 ansible_host=ПОДСТАВИТЬ_IP_LB ansible_user=ubuntu
7. Настроить серверы

bash
cd ..
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
8. Проверить работу

bash
curl http://ПОДСТАВИТЬ_IP_LB
9. Удалить всё после проверки

bash
cd terraform
terraform destroy -auto-approve
Или одной командой (Makefile)

bash
make setup   # подготовка
make deploy  # развернуть
make destroy # удалить
Что получится в итоге

2 веб-сервера с Nginx в Docker
Балансировщик Nginx распределяет трафик
PostgreSQL база данных
Требования к системе

Terraform >= 1.0
Ansible >= 2.9
Python 3.9+
Структура проекта

text
terraform/          - конфигурация инфраструктуры
ansible/           - плейбуки и inventory
Makefile           - команды для управления
README.md          - документация