#!/bin/sh

ES_CLASSPATH=$ES_HOME/lib/elasticsearch-5.1.1.jar:$ES_HOME/lib/*

if [ "x$ES_MIN_MEM" = "x" ]; then
    ES_MIN_MEM=256m
fi
if [ "x$ES_MAX_MEM" = "x" ]; then
    ES_MAX_MEM=1g
fi
if [ "x$ES_HEAP_SIZE" != "x" ]; then
    ES_MIN_MEM=$ES_HEAP_SIZE
    ES_MAX_MEM=$ES_HEAP_SIZE
fi

# min and max heap sizes should be set to the same value to avoid
# stop-the-world GC pauses during resize, and so that we can lock the
# heap in memory on startup to prevent any of it from being swapped
# out.
ES_JAVA_OPTS="$ES_JAVA_OPTS -Xms${ES_MIN_MEM}"
ES_JAVA_OPTS="$ES_JAVA_OPTS -Xmx${ES_MAX_MEM}"

# new generation
if [ "x$ES_HEAP_NEWSIZE" != "x" ]; then
    ES_JAVA_OPTS="$ES_JAVA_OPTS -Xmn${ES_HEAP_NEWSIZE}"
fi

# max direct memory
if [ "x$ES_DIRECT_SIZE" != "x" ]; then
    ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:MaxDirectMemorySize=${ES_DIRECT_SIZE}"
fi

# reduce the per-thread stack size
ES_JAVA_OPTS="$ES_JAVA_OPTS -Xss256k"

# set to headless, just in case
ES_JAVA_OPTS="$ES_JAVA_OPTS -Djava.awt.headless=true"

# Force the JVM to use IPv4 stack
if [ "x$ES_USE_IPV4" != "x" ]; then
  ES_JAVA_OPTS="$ES_JAVA_OPTS -Djava.net.preferIPv4Stack=true"
fi

ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:+UseParNewGC"
ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:+UseConcMarkSweepGC"

ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:CMSInitiatingOccupancyFraction=75"
ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:+UseCMSInitiatingOccupancyOnly"

# GC logging options
if [ "x$ES_USE_GC_LOGGING" != "x" ]; then
  ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:+PrintGCDetails"
  ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:+PrintGCTimeStamps"
  ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:+PrintClassHistogram"
  ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:+PrintTenuringDistribution"
  ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:+PrintGCApplicationStoppedTime"
  ES_JAVA_OPTS="$ES_JAVA_OPTS -Xloggc:/var/log/elasticsearch/gc.log"
fi

# Causes the JVM to dump its heap on OutOfMemory.
ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError"
# The path to the heap dump location, note directory must exists and have enough
# space for a full heap dump.
#ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:HeapDumpPath=$ES_HOME/logs/heapdump.hprof"

# Disables explicit GC
ES_JAVA_OPTS="$ES_JAVA_OPTS -XX:+DisableExplicitGC"
