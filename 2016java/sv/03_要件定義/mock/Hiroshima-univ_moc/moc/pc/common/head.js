document.write('\
<!-- ★ロゴ画像のスペースは（base.css）で調整 -->\
<div class="logo">若手研究者キャリア開発のためのeポートフォリオシステム<span>Home for Innovative Researchers and Academic Knowledge Users</span></div>\
\
<!-- !nav sub（CLOSEは必ず最後） -->\
<ul>\
<li><a href="portal_month.html" onClick="demo_homenavigation();">HOME</a></li>\
<li><a href="#">操作説明</a></li> \
<li><a href="all_login.html">LOGOUT</a></li>\
<li><a href="#" onClick="window.close(); return false;">CLOSE</a></li>\
</ul>\
\
<!-- !time -->\
<p>2015.05.20（18:42:56）</p>\
');

// home-onclick  demo-action  ADD.
document.write('\
<script type="text/javascript">\
function demo_homenavigation() {\
var url = location.href;\
var idx = url.indexOf("/kojin_");\
if (idx > -1) {\
location.href="kojin_portal.html";\
return false;\
}\
idx = url.indexOf("/system_");\
if (idx > -1) {\
location.href="system_menu.html";\
return false;\
}\
}\
</script>\
');
