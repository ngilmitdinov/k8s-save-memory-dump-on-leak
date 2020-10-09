# Java Off-Heap Memory Leak Example

This is a little example project that consumes memory in Java in several ways to help demonstrate investigating memory 
leaks in Java for a presentation I gave on that topic.

Definitely do not look at this code for good practices. There are intentional leaks throughout.

## Presentation

https://drive.google.com/open?id=1TsjfLCuIKoE_Q3kDFtwoCkuLZ3mr2KpyPO-t-qeYDyU

## Requirements

  - Linux, only tested on CentOS, Fedora, Arch
  - GCC, for building the native library
  - Java, ideally Oracle JDK 1.8
  - Gnuplot, for displaying a plot of memory use
  - Jemalloc, built with profiling enabled
    - Not sure if your Jemalloc has profiling enabled? Run `jemalloc-config --config` and 
    look for `--enable-prof` in the output. If it's not there see the [Troubleshooting](#troubleshooting) section of 
    this readme

## Running

  - Unzip distribution and go into it's folder
    - `unzip OffHeapLeakExample-1.0-SNAPSHOT.zip`
    - `cd OffHeapLeakExample-1.0-SNAPSHOT`
  - Make sure you're running on Oracle JDK 1.8
    - `export JAVA_HOME=/path/to/oracle/jdk/on/your/machine`
  - Run the application from the root folder
    - `./bin/OffHeapLeakExample`
  - While it's paused for 20 seconds before using memory
    - Create a Native Memory Tracking baseline
    - Start logging memory to a file for plotting
    - `./bin/baseline_NMT_and_log_memory.sh`
  - Wait some time, got to let the application gobble up memory...
  - Look at memory use
    - `./bin/plot_memory.gnuplot`
    - Looking higher than expected?
  - See what the JVM has to say about the heap
    - `jmap -heap <pid>`
  - Investigate the heap and maybe buffers with VisualVM
    - `jvisualvm` or `visualvm`
  - Check out diff between the Native Memory Tracking baseline taken and now: 
    - Summary diff (usually good enough): `jcmd <pid> VM.native_memory summary.diff`
    - Detail diff (usually too much detail): `jcmd <pid> VM.native_memory detail.diff`
  - Nothing particularly obvious there to explain endless memory use? Can kill the application now
  - Generate memory allocation diagrams from the Jemalloc profiles that were recorded
    - `./bin/jeprof_diagrams.sh`
  - Hopefully by now you've spotted where the memory is going!
  
### What do the scripts do?

#### `./bin/OffHeapLeakExample`

This script is generated by Gradle and in general just runs `java` with a classpath including the project jar and 
specifying the main class to run.

The gradle script does add some extra bits to this command which you might want to take note of:

  - Setting the heap size (`-Xms` & `-Xmx`): [./build.gradle#L34](./build.gradle#L34) & [./build.gradle#L35](./build.gradle#L35)
  - Enabled Native Memory Tracking: [./build.gradle#L36](./build.gradle#L36)
  - Use jemalloc instead of system default malloc: [./build.gradle#L43](./build.gradle#L43)
  - Set up jemalloc profiling arguments: [./build.gradle#L46](./build.gradle#L46)

#### `./bin/baseline_NMT_and_log_memory.sh`

This script find the pid for a process with the main class in its command string.

With that it takes a Native Memory Tracking baseline using the following command: `jcmd ${PID} VM.native_memory baseline`

It then starts to loop every half-second reading the Resident Set Size value from `/proc/${PID}/status` 
and writing it to a file, ./memory.log

#### `./bin/plot_memory.gnuplot`

Not a shell script but an executable file that runs gnuplot (requires gnuplot-wx installed) to plot the resident set use
over time.

#### `./bin/jeprof_diagrams.sh`

Calls the `jeprof` command with input of all the jeprof.*.heap files and just the latest one to generate graphviz files.

The graphviz files are then converted to image (PNG) files for easy viewing.


## Building

Build using `gradle assemble` which should generate an archive containing the distributable code in build/distributions

### Changing QuestionableJniLib

  - Change to the JNI projects Java directory
    - `cd ./QuestionableJniLib/src/main/java`
  - Generate header file
    - `javah -jni -d ./../c uk.co.palmr.offheapleakexample.jni.QuestionableJniLib`


## Troubleshooting

Below are some example error messages you might get when trying to run this project and commands.

[If you use Arch Linux, these instructions should help.](./arch_linux_instructions.md)

[If you use a Redhat based distribution, like Fedora or CentOS, these instructions should help.](./redhat_linux_instructions.md)

### Jemalloc

If you see lines in the stdout from the application like:

 > \<jemalloc>: Invalid conf pair: prof:true

Then the jemalloc on your machine was not compiled with profiling enabled.

### JMAP

If you run `jmap -heap <pid>` and get an error like this:

```
Exception from jmap -heap:
Exception in thread "main" java.lang.reflect.InvocationTargetException
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:606)
	at sun.tools.jmap.JMap.runTool(JMap.java:197)
	at sun.tools.jmap.JMap.main(JMap.java:128)
Caused by: java.lang.RuntimeException: unknown CollectedHeap type : class sun.jvm.hotspot.gc_interface.CollectedHeap
	at sun.jvm.hotspot.tools.HeapSummary.run(HeapSummary.java:146)
	at sun.jvm.hotspot.tools.Tool.start(Tool.java:221)
	at sun.jvm.hotspot.tools.HeapSummary.main(HeapSummary.java:40)
	... 6 more
```

Your JVM is missing debug symbols. You can check this by running `file /usr/lib/jvm/java-8-openjdk/bin/java` (or 
whatever the path is to the Java runtime being used) and checking if the output ends in `stripped`.
