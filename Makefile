.PHONY: all deps ansible_deps vagrant-deps clean

all: deps

terraform-deps:
	@ansible-playbook -i hosts playbooks/install_terraform.yml
	@ansible-playbook -i hosts playbooks/kdevops_terraform.yml 
	@if [ -d terraform ]; then \
		make -C terraform deps; \
	fi

vagrant-deps:
	@ansible-playbook -i hosts playbooks/install_vagrant.yml
	@ansible-playbook -i hosts playbooks/libvirt_user.yml
	@ansible-playbook -i hosts playbooks/kdevops_vagrant.yml

ansible_deps:
	@ansible-galaxy install --force -r requirements.yml

deps: ansible_deps terraform-deps vagrant-deps
	@echo Installed dependencies

terraform-clean:
	@if [ -d terraform ]; then \
		make -C terraform clean ; \
	fi

clean: terraform-clean
	@echo Cleaned up
