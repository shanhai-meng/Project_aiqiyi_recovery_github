#!/usr/bin/python
# -*- coding:utf-8 -*-

import sys
import json

if sys.version > '3':
	import subprocess
else:
	import commands as subprocess

MultiDialStatusFile = "/tmp/multidialstatus.json"

class ConvergeSummary:
	TotalLines = 0
	OkLines = 0
	Sn = ""
	Mode = ""
	MultiDial = []
	Version = ""
	Proto = ""
	Balance = ""
	Errcode = 0
	ErrMsg = ""

summary = ConvergeSummary()

def RunSysCmd(cmd):
	ret = subprocess.getstatusoutput(cmd)
	return ret[0], ret[1]

def ConvertSpeed(bps):
	units = ['bps', 'Kbps', 'Mbps', 'Gbps', 'Tbps']
	index = 0
	bps *= 8
	while bps >= 1024 and index < len(units)-1:
		bps /= 1024.0
		index += 1
	return "{:.2f}{}".format(bps, units[index])

def DumpIPv6(ipaddr6):
	if ipaddr6 != "":
		return "true"
	else:
		return "false"

def ObtainMultiDialStatus():
	global summary

	try:
		with open(MultiDialStatusFile) as f:
			config = json.load(f)
			summary.TotalLines = config['totalline']
			summary.OkLines = config['connectedline']
			summary.Sn = config['sn']
			summary.Mode = config['runmode']
			summary.MultiDial = config['multidial']
			summary.Version = config['version']
			summary.Balance = config['hostconfig']['load_balance']
			summary.Errcode = config['errcode']
			summary.ErrMsg = config['errmsg']

	except:
		print("obtain multi dial status failed! please update plugin version!")
		sys.exit(0)

	if len(summary.MultiDial) > 0:
		try:
			summary.Proto = summary.MultiDial[0]['proto']
		except:
			print("obtain proto field failed!please update plugin version!")
			sys.exit(0)

	if summary.Sn.startswith('XYBM'):
		_, summary.Sn = RunSysCmd("cat /etc/xyvod/device_id")

def OutputSummary():

	fmtStr = '%-20s%-9s%-14s%-14s%-12s%-9s%-9s%-5s%-20s'
	print(fmtStr % ("SN", "VERSION", "MODE", "PROTO", "TOTAL_LINES", "OK_LINES", "BALANCE", "CODE", "MSG"))
	print(fmtStr % (summary.Sn, summary.Version, summary.Mode, summary.Proto, summary.TotalLines, summary.OkLines, summary.Balance, summary.Errcode, summary.ErrMsg))

	print("")

	NicMaxLen = len("NIC")
	IpMaxLen = len("IP")
	NetmaskMaxLen = len("NETMASK")
	GatewayMaxLen = len("GATEWAY")
	LTimeMaxLen = len("LTIME")
	UpspeedMaxLen = len("UPSPEED")
	IPv6MaxLen = len("IPV6")
	for line in summary.MultiDial:
		if len(line['nic']) > NicMaxLen:
			NicMaxLen = len(line['nic'])

		if len(line['ipaddr']) > IpMaxLen:
			IpMaxLen = len(line['ipaddr'])

		if len(line['netmask']) > NetmaskMaxLen:
			NetmaskMaxLen = len(line['netmask'])

		if len(line['gateway']) > GatewayMaxLen:
			GatewayMaxLen = len(line['gateway'])

		if len(str(line['statustime'])) > LTimeMaxLen:
			LTimeMaxLen = len(str(line['statustime']))

		if len(ConvertSpeed(line['upspeed'])) > UpspeedMaxLen:
			UpspeedMaxLen = len(ConvertSpeed(line['upspeed']))

		if len(DumpIPv6(line['ipaddr6'])) > IPv6MaxLen:
			UpspeedMaxLen = len(ConvertSpeed(line['upspeed']))
			IPv6MaxLen = len(DumpIPv6(line['ipaddr6']))

	if summary.Proto == "pppoe":

		UsernameMaxLen = len("USERNAME")
		PasswordMaxLen = len("PASSWORD")
		for line in summary.MultiDial:
			if len(line['username']) > UsernameMaxLen:
				UsernameMaxLen = len(line['username'])

			if len(line['password']) > PasswordMaxLen:
				PasswordMaxLen = len(line['password'])

		if UsernameMaxLen > 64:
			UsernameMaxLen = 64

		if PasswordMaxLen > 64:
			PasswordMaxLen  = 64

		fmtStr = "%-4s%-4s%-"+str(NicMaxLen+1)+"s%-5s%-"+str(UsernameMaxLen+1)+"s%-"+str(PasswordMaxLen+1)+"s%-"+str(IpMaxLen+1)+"s%-"+str(GatewayMaxLen+1)+"s%-18s%-"+str(LTimeMaxLen+1)+"s%-"+str(UpspeedMaxLen+1)+"s%-"+str(IPv6MaxLen+1)+"s%-5s%-10s"
		print(fmtStr % ("ID", "MID", "NIC", "VLAN", "USERNAME", "PASSWORD", "IP", "GATEWAY", "MAC", "LTIME", "UPSPEED", "IPV6", "CODE", "MSG"))
		for line in summary.MultiDial:
			print(fmtStr % (line['lineid'], line['magicid'], line['nic'], line['vlanid'], line['username'], line['password'], line['ipaddr'], line['gateway'], line['macconf'], line['statustime'], ConvertSpeed(line['upspeed']), DumpIPv6(line['ipaddr6']), line['errcode'], line['errmsg']))
	else:
		fmtStr = "%-4s%-4s%-"+str(NicMaxLen+1)+"s%-5s%-"+str(IpMaxLen+1)+"s%-"+str(NetmaskMaxLen+1)+"s%-"+str(GatewayMaxLen+1)+"s%-18s%-"+str(LTimeMaxLen+1)+"s%-"+str(UpspeedMaxLen+1)+"s%-"+str(IPv6MaxLen+1)+"s%-5s%-10s"
		print(fmtStr % ("ID", "MID", "NIC", "VLAN", "IP", "NETMASK", "GATEWAY", "MAC", "LTIME", "UPSPEED", "IPV6", "CODE", "MSG"))
		for line in summary.MultiDial:
			print(fmtStr % (line['lineid'], line['magicid'], line['nic'], line['vlanid'], line['ipaddr'], line['netmask'], line['gateway'], line['macconf'], line['statustime'], ConvertSpeed(line['upspeed']), DumpIPv6(line['ipaddr6']), line['errcode'], line['errmsg']))

def OutputSysCost():
	if summary.Sn.startswith('ES01') or summary.Sn.startswith('EC01'):
		_, out = RunSysCmd("top -n 1 |grep -Ew \"virtualrouter|COMMAND\" 2>&1 |column -t")
	else:
		_, out = RunSysCmd("TERM=dumb top -bn 1 -w 512 |grep -wE \"virtualrouter|COMMAND\" 2>&1 |column -t")
	print(out)

	print("")

	if summary.Sn.startswith('ES01') or summary.Sn.startswith('EC01'):
		_, out = RunSysCmd("ps -eo pid,comm,etime,time,vsz,rss |grep -E \"virtualrouter|COMMAND\"")
	else:
		_, out = RunSysCmd("ps -eo pid,comm,lstart,etime |grep -Ew \"virtualrouter|COMMAND\"")
	print(out)
	print("")
	

def main():

	ObtainMultiDialStatus()

	if len(sys.argv) == 2 and sys.argv[1] == "sys":
		OutputSysCost()

	OutputSummary()


if __name__ == "__main__":
	main()
