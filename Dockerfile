FROM sixteenbitt/kubemem:glibc AS kubemem

FROM domblack/oracle-jdk8
WORKDIR /app
COPY . /app
COPY --from=kubemem /bin/kubemem /bin/kubemem
RUN yum update -y && yum install -y java-devel gcc gcc-c++ g++ && /app/gradlew clean build && jar xf /app/build/distributions/OffHeapLeakExample-1.0-SNAPSHOT.zip && chmod +x /app/OffHeapLeakExample-1.0-SNAPSHOT/bin/OffHeapLeakExample && chmod +x /app/jmap-entrypoint.sh
WORKDIR /app/OffHeapLeakExample-1.0-SNAPSHOT
ENTRYPOINT bin/OffHeapLeakExample
