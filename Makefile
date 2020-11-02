install: 
	cp cmd/main.go .
	go install
	rm -f main.go

build: 
	cd cmd && go build && mv cmd ../lflxp-orzdba

push: pull
	git add .
	git commit -m "${m}"
	git push origin $(shell git branch|grep '*'|awk '{print $$2}')

pull:
	git pull origin $(shell git branch|grep '*'|awk '{print $$2}')

clean:
	rm -f cmd/cmd
	rm -f lflxp-orzdba