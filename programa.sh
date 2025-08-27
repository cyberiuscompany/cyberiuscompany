#!/bin/bash
OUTDIR=/tmp/nw_diag_$(date +%Y%m%d%H%M%S)
mkdir -p $OUTDIR

echo "== HOST INFO ==" > $OUTDIR/summary.txt
uname -a >> $OUTDIR/summary.txt
echo "" >> $OUTDIR/summary.txt
echo "== DISK & MEM ==" >> $OUTDIR/summary.txt
df -h >> $OUTDIR/summary.txt
free -m >> $OUTDIR/summary.txt
echo "" >> $OUTDIR/summary.txt
echo "== TOP PROCS ==" >> $OUTDIR/summary.txt
top -b -n1 | head -n 30 >> $OUTDIR/summary.txt

echo "== PROCESSES RELATED TO CONCENTRATOR ==" > $OUTDIR/processes.txt
ps aux | egrep -i 'concentrator|nwconcentrator|nwdecoder|logcollector|decoder' >> $OUTDIR/processes.txt

echo "== LISTENING PORTS (filtered) ==" > $OUTDIR/ports.txt
ss -lntup | egrep '514|5985|5986|480|4800|470|4700' >> $OUTDIR/ports.txt
netstat -tulnp 2>/dev/null | egrep '514|5985|5986|480|4800|470|4700' >> $OUTDIR/ports.txt

echo "== LAST LOG LINES: concentrator, decoder, collector, system ==" > $OUTDIR/logs_tail.txt
for f in /var/log/netwitness/concentrator/* /var/netwitness/concentrator/logs/* /var/log/netwitness/decoder/* /var/netwitness/logcollector/logs/* /var/log/messages; do
  if [ -e "$f" ]; then
    echo -e "\n--- $f ---" >> $OUTDIR/logs_tail.txt
    tail -n 200 "$f" >> $OUTDIR/logs_tail.txt
  fi
done

echo "== Health & Wellness: searches for Concentrator alerts ==" > $OUTDIR/hw_check.txt
grep -i -E 'concentrator meta rate|meta rate zero|concentrator not' /var/log/messages /var/log/netwitness/* 2>/dev/null | tail -n 200 >> $OUTDIR/hw_check.txt

echo "Diagnostic files saved to $OUTDIR"
ls -l $OUTDIR
