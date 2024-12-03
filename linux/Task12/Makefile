task1:
	@cd ../Task1/ && \
	chmod +x main.sh && \
	bash main.sh

task2:
	@cd ../Task2/ && \
	chmod +x as2-archive.bash && \
	./as2-archive.bash

task3:
	@cd ../Task3/ && \
	chmod +x ssh_remote_server.sh && \
	./ssh_remote_server.sh && \
	echo "Checking connection" && \
	ssh root@167.99.244.46

task4:
	@cd ../Task4/ && \
	sudo chmod +x install_go.sh && \
	bash ./install_go.sh && \
	export PATH=$$PATH:/usr/local/go/bin && \
	export GOPATH=/opt/go/.go && \
	export PATH=$$PATH:$$GOPATH/bin && \
	go build -o main main.go && \
	sudo chmod +x main setup_logrotate.sh ../Task7/logs_permissions.sh ../Task5/create_executor.sh && \
	echo "Creating 'executor' to give him proper permissions" && \
	sudo bash ../Task5/create_executor.sh && \
	sudo ./setup_logrotate.sh
 
task5:
	@cd ../Task5/ && \
	sudo chmod +x create_service.sh && \
	sudo ./create_service.sh && \
	echo "Checking" && \
	sudo systemctl status go_api.service

task6:
	@cd ../Task6/ && \
	sudo chmod +x top_5.sh && \
	./top_5.sh

task7:
	@cd ../Task7/ && \
	sudo chmod +x logs_permissions.sh && \
	./logs_permissions.sh 

task8:
	@cd ../Task8/ && \
	sudo chmod +x script.sh && \
	echo "example.nomad before changing the job name:" && \
	cat /home/linux/Task8/example.nomad && \
	./script.sh test404
	echo "example.nomad after changing the job name:" && \
	cat /home/linux/Task8/example.nomad

task9:
	@cd ../Task9/ && \
	sudo chmod +x iptables_test.sh reset_iptables.sh && \
	./iptables_test.sh

task10:
	@cd ../Task10/ && \
	sudo chmod +x config.sh && \
	./config.sh

task11:
	@cd ../Task11/ && \
	sudo chmod +x load_balancer.sh && \
	bash load_balancer.sh 8000-8005