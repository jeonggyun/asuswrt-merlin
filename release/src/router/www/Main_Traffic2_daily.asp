<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">

<title><#Web_Title#> - Daily Traffic</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="tmmenu.css">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>

<script type='text/javascript'>

wan_route_x = '<% nvram_get("wan_route_x"); %>';
wan_nat_x = '<% nvram_get("wan_nat_x"); %>';
wan_proto = '<% nvram_get("wan_proto"); %>';
lan_ipaddr = '<% nvram_get("lan_ipaddr"); %>';
lan_netmask = '<% nvram_get("lan_netmask"); %>';

try {
//	<% ipt_bandwidth("daily"); %>
}
catch (ex) {
	daily_history = [];
}
cstats_busy = 0;
if (typeof(daily_history) == 'undefined') {
	daily_history = [];
	cstats_busy = 1;
}


var filterip = [];
var filteripe = [];
var filteripe_before = [];
var dateFormat = 1;
var scale = 2;

hostnamecache = [];


function save()
{
	cookie.set('daily', scale, 31);
}

function getYMD(n)
{
	// [y,m,d]
	return [(((n >> 16) & 0xFF) + 1900), ((n >>> 8) & 0xFF), (n & 0xFF)];
}

function redraw()
{
	var h;
	var grid;
	var rows;
	var ymd;
	var i, b, d;
	var fskip;

	var style_open;
	var style_close;

	rows = 0;
	block = '';
	gn = 0;

	grid = '<table width="730px" class="FormTable_NWM">';
	grid += "<tr><th style=\"height:30px;\"><#Date#></th>";
	grid += "<th>Host</th>";
	grid += "<th>Download</th>";
	grid += "<th>Upload</th>";
	grid += "<th><#Total#></th></tr>";


	if (daily_history.length > 0) {
		for (i = 0; i < daily_history.length; ++i) {
			fskip=0;
			style_open = "";
			style_close = "";

			b = daily_history[i];

			if (getRadioValue(document.form._f_show_zero) == 0) {
				if ((b[2] < 1) || (b[3] < 1))
					continue;
			}

			if (document.form._f_begin_date.value.toString() != '0') {
				if (b[0] < document.form._f_begin_date.value)
					continue;
			}

			if (document.form._f_end_date.value.toString() != '0') {
				if (b[0] > document.form._f_end_date.value)
					continue;
			}

			if (b[1] == fixIP(ntoa(aton(lan_ipaddr) & aton(lan_netmask)))) {
				if (getRadioValue(document.form._f_show_subnet) == 1) {
					style_open='<span style="color: yellow;">';
					style_close='</span>';
				} else {
					continue;
				}
			}

			if (filteripe.length>0) {
				fskip = 0;
				for (var x = 0; x < filteripe.length; ++x) {
					if (b[1] == filteripe[x]){
						fskip=1;
						break;
					}
				}
				if (fskip == 1) continue;
			}

			if (filterip.length>0) {
				fskip = 1;
				for (var x = 0; x < filterip.length; ++x) {
					if (b[1] == filterip[x]){
						fskip=0;
						break;
					}
				}
				if (fskip == 1) continue;
			}

			var h = b[1];

			if (getRadioValue(document.form._f_show_hostnames) == 1) {
				if(hostnamecache[b[1]] != null) {
					h = "<b>" + hostnamecache[b[1]] + '</b>  <small>(' + b[1] + ')</small>';

				}
			}

			var ymd = getYMD(b[0]);
			d = [ymdText(ymd[0], ymd[1], ymd[2]), h, rescale(b[2]), rescale(b[3]), rescale(b[2]+b[3])];

			grid += addrow(((rows & 1) ? 'odd' : 'even'), ymdText(ymd[0], ymd[1], ymd[2]), style_open + h + style_close, rescale(b[2]), rescale(b[3]), rescale(b[2]+b[3]));
			++rows;
		}
	}

	if(rows == 0)
		grid +='<tr><td style="color:#FFCC00;" colspan="5"><#IPConnection_VSList_Norule#></td></tr>';

	E('bwm-daily-grid').innerHTML = grid + '</table>';
}

function update_display(option, value) {
	cookie.set('ipt_' + option, value);
	redraw();
}

function update_filter() {
	var i;

	if (document.form._f_filter_ip.value.length>0) {
		filterip = document.form._f_filter_ip.value.split(',');
		for (i = 0; i < filterip.length; ++i) {
			if ((filterip[i] = fixIP(filterip[i])) == null) {
				filterip.splice(i,1);
			}
		}
		document.form._f_filter_ip.value = (filterip.length > 0) ? filterip.join(',') : '';
	} else {
		filterip = [];
	}

	if (document.form._f_filter_ipe.value.length>0) {
		filteripe = document.form._f_filter_ipe.value.split(',');
		for (i = 0; i < filteripe.length; ++i) {
			if ((filteripe[i] = fixIP(filteripe[i])) == null) {
				filteripe.splice(i,1);
			}
		}
		document.form._f_filter_ipe.value = (filteripe.length > 0) ? filteripe.join(',') : '';
	} else {
		filteripe = [];
	}

	cookie.set('ipt_addr_shown', (filterip.length > 0) ? filterip.join(',') : '', 1);
	cookie.set('ipt_addr_hidden', (filteripe.length > 0) ? filteripe.join(',') : '', 1);

	redraw();
}

function update_visibility() {
	s = getRadioValue(document.form._f_show_options);

	for (i = 0; i < 5; i++) {
		showhide("adv" + i, s);
	}

	cookie.set('ipt_options', s);

}

function addrow(rclass, rtitle, host, dl, ul, total) {
        return '<tr class="' + rclass + '">' +
                '<td class="rtitle">' + rtitle + '</td>' +
                '<td class="host">' + host + '</td>' +
                '<td class="dl">' + dl + '</td>' +
                '<td class="ul">' + ul + '</td>' +
                '<td class="total">' + total + '</td>' +
                '</tr>';
}


function init() {

	if (<% nvram_get("cstats_enable"); %> != '1') return;

// TODO: fixme/remove me
	if ((c = cookie.get('daily')) != null) {
		if (c.match(/^([0-2])$/)) {
			E('scale').value = scale = RegExp.$1 * 1;
		}
	}

	if ((c = cookie.get('ipt_addr_shown')) != null) {
		if (c.length>6) {
			document.form._f_filter_ip.value = c;
			filterip = c.split(',');
		}
	}

	if ((c = cookie.get('ipt_addr_hidden')) != null) {
		if (c.length>6) {
			document.form._f_filter_ipe.value = c;
			filteripe = c.split(',');
		}
	}

	setRadioValue(document.form._f_show_options , (((c = cookie.get('ipt_options')) != null) && (c == '1')));
	setRadioValue(document.form._f_show_subnet , (((c = cookie.get('ipt_subnet')) != null) && (c == '1')));
	setRadioValue(document.form._f_show_hostnames , (((c = cookie.get('ipt_hostnames')) != null) && (c == '1')));
	setRadioValue(document.form._f_show_zero , (((c = cookie.get('ipt_zero')) != null) && (c == '1')));
	update_visibility();

	initDate('ymd');

	daily_history.sort(cmpDualFields);
	init_filter_dates();
	populateCache();
	redraw();
}

function init_filter_dates() {
	var dates = [];
	if (daily_history.length > 0) {
		for (var i = 0; i < daily_history.length; ++i) {
			dates.push('0x' + daily_history[i][0].toString(16));
		}
		if (dates.length > 0) {
			dates.sort();
			for (var j = 1; j < dates.length; j++ ) {
				if (dates[j] === dates[j - 1]) {
					dates.splice(j--, 1);
				}
			}
		}
	}
	var d = new Date();
	free_options(document.form._f_begin_date);
	free_options(document.form._f_end_date);

	for (var i = 0; i < dates.length; ++i) {
		var ymd = getYMD(dates[i]);
		add_option(document.form._f_begin_date,ymdText(ymd[0], ymd[1], ymd[2]), dates[i], (i == 0));
		add_option(document.form._f_end_date,ymdText(ymd[0], ymd[1], ymd[2]), dates[i], ((ymd[0]==d.getFullYear()) && (ymd[1]==d.getMonth()) && (ymd[2]==d.getDate())) );
	}
}

function update_date_format(o, f) {
	changeDate(o, f);
	init_filter_dates();
}

function cmpDualFields(a, b) {

	if (cmpHist(a, b) == 0)
		return aton(a[1])-aton(b[1]);
	else
		return cmpHist(a,b);
}

function populateCache() {
	var s;

	// Retrieve NETBIOS client names through networkmap list
	// This might NOT be accurate if the device IP is dynamic.
	// TODO: Should we force a network scan first to update that list?
	//       See what happens if we access this right after a reboot
	var client_list_array = '<% get_client_detail_info(); %>';

	if (client_list_array) {
		s = client_list_array.split('<');
		for (var i = 0; i < s.length; ++i) {
			var t = s[i].split('>');
			if (t.length == 7) {
				if (t[1] != '')
					hostnamecache[t[2]] = t[1].split(' ').splice(0,1);
			}
		}
	}

	// Retrieve manually entered descriptions in static lease list
	// We want to override netbios names if we havee a better name

	dhcpstaticlist = '<% nvram_get("dhcp_staticlist"); %>';

	if (dhcpstaticlist) {
		s = dhcpstaticlist.split('&#60');
		for (var i = 0; i < s.length; ++i) {
			var t = s[i].split('&#62');
			if ((t.length == 3) || (t.length == 4)) {
				if (t[2] != '')
					hostnamecache[t[1]] = t[2].split(' ').splice(0,1);
			}
		}
	}

	hostnamecache[fixIP(ntoa(aton(lan_ipaddr) & aton(lan_netmask)))] = 'LAN';
}


// TODO: Move me to external file - also used by OpenVPN pages
function getRadioValue(obj) {
	for (var i=0; i<obj.length; i++) {
		if (obj[i].checked)
			return obj[i].value;
	}
	return 0;
}

function setRadioValue(obj,val) {
	for (var i=0; i<obj.length; i++) {
		if (obj[i].value==val)
			obj[i].checked = true;
	}
}


function switchPage(page){
	if(page == "1")
		location.href = "/Main_TrafficMonitor_realtime.asp";
	else if(page == "2")
		location.href = "/Main_TrafficMonitor_last24.asp";
	else if(page == "4")
		location.href = "/Main_TrafficMonitor_monthly.asp";
	else
		return false;
}

</script>
</head>

<body onload="show_menu();init();" >

<div id="TopBanner"></div>

<div id="Loading" class="popup_bg"></div>

<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" action="apply.cgi" target="hidden_frame">
<input type="hidden" name="current_page" value="Main_Traffic2_daily.asp">
<input type="hidden" name="next_page" value="Main_Traffic2_daily.asp">
<input type="hidden" name="next_host" value="">
<input type="hidden" name="group_id" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="">
<input type="hidden" name="action_wait" value="">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">

<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
	<td width="23">&nbsp;</td>

<!--=====Beginning of Main Menu=====-->
	<td valign="top" width="202">
	 	<div id="mainMenu"></div>
	 	<div id="subMenu"></div>
	</td>

    	<td valign="top">
		<div id="tabMenu" class="submenuBlock"></div>
<!--===================================Beginning of Main Content===========================================-->
      	<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
	 	<tr>
         		<td align="left"  valign="top">
				<table width="100%" border="0" cellpadding="4" cellspacing="0" class="FormTitle" id="FormTitle">
				<tbody>
				<!--===================================Beginning of QoS Content===========================================-->
	      		<tr>
	      			<td bgcolor="#4D595D" valign="top">
	      				<table width="740px" border="0" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3">
						<tr><td><table width=100%" >
        			<tr>

						<td  class="formfonttitle" align="left">
										<div style="margin-top:5px;"><#Menu_TrafficManager#> - Daily Hosts Traffic</div>
									</td>
          				<td>
     							<div align="right">
			    					<select class="input_option" style="width:120px" onchange="switchPage(this.options[this.selectedIndex].value)">
											<!--option><#switchpage#></option-->
											<option value="1"><#menu4_2_1#></option>
											<option value="2"><#menu4_2_2#></option>
											<option value="3" selected><#menu4_2_3#></option>
											<option value="4">Monthly</option>
										</select>

									</div>
								</td>
        			</tr>
					</table></td></tr>

        			<tr>
          				<td height="5"><img src="images/New_ui/export/line_export.png" /></td>
        			</tr>
						<tr>
							<td bgcolor="#4D595D">
								<table width="730"  border="1" align="left" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
									<thead>
										<tr>
											<td colspan="2"><#t2BC#></td>
										</tr>
									</thead>
									<tbody>
										<tr class='even'>
											<th width="40%"><#Date#></th>
											<td>
												<select class="input_option" style="width:130px" onchange='update_date_format(this, "ymd")' id='dafm'>
													<option value=0>yyyy-mm-dd</option>
													<option value=1>mm-dd-yyyy</option>
													<option value=2>mmm, dd, yyyy</option>
													<option value=3>dd.mm.yyyy</option>
												</select>
											</td>
										</tr>
										<tr class='even'>
											<th width="40%"><#Scale#></th>
											<td>
												<select style="width:70px" class="input_option" onchange='changeScale(this)' id='scale'>
													<option value=0>KB</option>
													<option value=1>MB</option>
													<option value=2 selected>GB</option>
												</select>
											</td>
										</tr>
										<tr>
											<th width="40%">Date range</th>
											<td>
												<div>
													<label>From:</label>
													<select name="_f_begin_date" onchange="redraw();" class="input_option" style="width:120px">
													</select>
													<label>To:</label>
													<select name="_f_end_date" onchange="redraw();" class="input_option" style="width:120px">
													</select>
												</div>
											</td>
										</tr>

										<tr>
											<th>Display advanced filter options</th>
											<td>
												<input type="radio" name="_f_show_options" class="input" value="1" onclick="update_visibility();"><#checkbox_Yes#>
												<input type="radio" name="_f_show_options" class="input" checked value="0" onclick="update_visibility();"><#checkbox_No#>
											</td>
					 					</tr>
										<tr id="adv0">
											<th>List of IPs to display (comma-separated):</th>
											<td>
<!-- TODO: filter out for digits, dots and commas -->
												<input type="text" maxlength="512" class="input_32_table" name="_f_filter_ip" onchange="update_filter();">
											</td>
										</tr>
										<tr id="adv1">
											<th>List of IPs to exclude (comma-separated):</th>
											<td>
<!-- TODO: filter out for digits, dots and commas -->
												<input type="text" maxlength="512" class="input_32_table" name="_f_filter_ipe" onchange="update_filter();">
											</td>
										</tr>

										<tr id="adv2">
											<th>Display hostnames</th>
								        		<td>
													<input type="radio" name="_f_show_hostnames" class="input" value="1" checked onclick="update_display('hostnames',1);"><#checkbox_Yes#>
													<input type="radio" name="_f_show_hostnames" class="input" value="0" onclick="update_display('hostnames',0);"><#checkbox_No#>
								   			</td>
										</tr>
										<tr id="adv3">
											<th>Display IPs with no traffic</th>
								        		<td>
													<input type="radio" name="_f_show_zero" class="input" value="1" onclick="update_display('zero',1);"><#checkbox_Yes#>
													<input type="radio" name="_f_show_zero" class="input" value="0" checked onclick="update_display('zero',0);"><#checkbox_No#>
								   			</td>
										</tr>

										<tr id="adv4">
											<th>Show subnet totals</th>
								        		<td>
													<input type="radio" name="_f_show_subnet" class="input" value="1" onclick="update_display('subnet',1);"><#checkbox_Yes#>
													<input type="radio" name="_f_show_subnet" class="input" value="0" checked onclick="update_display('subnet',0);"><#checkbox_No#>
								   			</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
						<tr >
							<td>
								<div id='bwm-daily-grid' style='float:left'></div>
							</td>
						</tr>

	     					</table>
	     				</td>
	     			</tr>
				</tbody>
				</table>
			</td>
		</tr>
		</table>
		</div>
	</td>

    	<td width="10" align="center" valign="top">&nbsp;</td>
</tr>
</table>
<div id="footer"></div>
</body>
</html>


