This is fork memory-leak java application.

I am investigating the possibility of saving a memory dump when Kubernetes restarts pod due to OOM killer.  

Already tried:
1. Java Flgs: '-XX:+HeapDumpOnOutOfMemoryError' and '-XX:HeapDumpPath=/dumps/oom.bin' and EmpyDir volume. This is not solution, because java instruction do not have time to be executed after k8s OOMKiller.
2. WIP: Jmap in PreStop hook. This solution needs Persistent Volume for dump and liveness probe that fail container before k8s OOM, because k8s OOMKiller send SIGKILL (not SIGTERM) and PreStop hook didn't work.
3. Sidecar with Jmap. This solutuion needs to sharing pid with namespaces
