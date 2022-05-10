This is fork memory-leak java application.

I am investigating the possibility of saving a memory dump when Kubernetes restarts pod due to OOM killer.

Already tried:
### 1. :zzz: **NOT SOLUTION** :zzz: Java Flags.

'-XX:+HeapDumpOnOutOfMemoryError' and '-XX:HeapDumpPath=/dumps/oom.bin' and EmptyDir volume. This is not solution, because java instruction do not have time to be executed after k8s OOMKiller.

References:
- https://danlebrero.com/2018/11/20/how-to-do-java-jvm-heapdump-in-kubernetes/

### 2. :star: **SOLUTION** :star: Jmap in PreStop hook.

This solution needs Persistent Volume for dump and liveness probe that fail container before k8s OOM, because k8s OOMKiller send SIGKILL (not SIGTERM) and PreStop hook didn't work.

References:
- Liveness probe by: https://github.com/16Bitt/kubemem

### 3. **WIP** Sidecar with Jmap.
This solutuion needs to sharing pid with namespaces
