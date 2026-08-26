AWL_TAG ?= v0.19.0
AWL_UI_PORT ?= 8639

.stamp:
	mkdir -p .stamp

.stamp/build-awl-container: .stamp build/build.sh build/Dockerfile.build
	docker build --platform linux/amd64 -f build/Dockerfile.build -t awl-qnap-builder:latest build/
	touch .stamp/build-awl-container

.stamp/out_awl: .stamp/build-awl-container
	docker run --platform linux/amd64 --rm -v ${CURDIR}/out:/out -e AWL_TAG=${AWL_TAG} awl-qnap-builder
	touch .stamp/out_awl

.stamp/build-qdk-container: .stamp build/build-qpkg.sh build/Dockerfile.qpkg
	docker build --platform linux/amd64 -f build/Dockerfile.qpkg -t qdk:latest build/
	touch .stamp/build-qdk-container

.stamp/out_pkg: .stamp/build-qdk-container .stamp/out_awl
	docker run --platform linux/amd64 --rm -v ${CURDIR}/out:/out -v ${CURDIR}/data:/data -e AWL_TAG=${AWL_TAG} -e AWL_UI_PORT=${AWL_UI_PORT} qdk:latest
	touch .stamp/out_pkg

.PHONY: clean
clean:
	rm -rf out/pkg
	rm -f out/awl-*
