
# commands used ...
cmdCfInfo=$(/usr/bin/which cpufreq-info 2>/dev/null)
cmdCfSet=$(/usr/bin/which cpufreq-set  2>/dev/null)
cmdSudo=$(/usr/bin/which sudo  2>/dev/null)
# list of CPUs...
numCpu=$( [ -x "${cmdCfInfo}" ] && ${cmdCfInfo} | nl | egrep "analyzing CPU" | tr ":" " "  |  awk '{printf( "%s ", $4 )}' )
# executing cpufreq-set using sudo ...
cmdSudoCfSet=$( [ "$USER" == "root" ]  && echo ${cmdCfSet} || [ -x $cmdSudo ] && echo ${cmdSudo} ${cmdCfSet} )

# getCpuFreq: given a CPU index, returns the current frequency.
function getCpuFreq()
{
	idxCpu=$1
	freqCur=$( [ -x "${cmdCfInfo}" ] && ${cmdCfInfo} | nl | egrep -A 9 "analyzing CPU $idxCpu" | grep "current CPU frequency" | awk '{printf( "%s%s", $6, $7 )}' )
	echo "$freqCur"
}

# setCpuFreq:  Set the CPU frequency to min or max for the specified CPU by index
function setCpuFreq()
{
	idxCpu=$1
	modeCpu=$2
	freqMin=$( [ -x "${cmdCfInfo}" ] && ${cmdCfInfo} | nl | egrep -A 3 "analyzing CPU $idxCpu" | grep "hardware limits" | awk '{printf( "%s%s", $4, $5 )}' )
	freqMax=$( [ -x "${cmdCfInfo}" ] && ${cmdCfInfo} | nl | egrep -A 3 "analyzing CPU $idxCpu" | grep "hardware limits" | awk '{printf( "%s%s", $7, $8 )}' )
	cmdMin="${cmdSudoCfSet} -c ${idxCpu} -f ${freqMin}"
	cmdMax="${cmdSudoCfSet} -c ${idxCpu} -f ${freqMax}"
	echo "INFO:  cmdMin is = ${cmdMin}"
	echo "INFO:  cmdMax is = ${cmdMax}"

	if [ -x "$cmdCfSet" ] ; then
		sFormatter="INFO: CPU:%2d      %-18s %s\\n"
		printf "$sFormatter" $idxCpu "Current Frequency:" $(getCpuFreq $idxCpu) 
		[ "$modeCpu" == "min" ] && [ ! -e "$freqMin" ] && ${cmdMin}
		[ "$modeCpu" == "max" ] && [ ! -e "$freqMax" ] && ${cmdMax}  
		printf "$sFormatter" $idxCpu "Updated Frequency:" $(getCpuFreq $idxCpu)
	fi
}

# setAllCpuFreq:  Call setCpuFreq() on all the CPUs...
function setAllCpuFreq()
{
	for idxCpu in ${numCpu} ; do 
		setCpuFreq $idxCpu $1; 
	done
}

# handy aliases - r-cpumode-performance = maximum CPU frequency; r-cpumode-powersave = minimum CPU frequency.
alias r-cpumode-performance='setAllCpuFreq max'
alias r-cpumode-powersave='setAllCpuFreq min'
