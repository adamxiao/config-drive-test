

function read(f)
{
    var fso, file, buffer
    fso = new ActiveXObject("Scripting.FileSystemObject");
    file = fso.OpenTextFile(f, 1);
    buffer = file.ReadAll();
    file.Close();
    fso = null;
    return buffer;
}

function send(buffer)
{
    if (buffer.length == 0) {
        WScript.Echo("not post data to send");
        return;
    }
    var objXML = new ActiveXObject("MSXML2.XMLHTTP")
    if (objXML == null) {
        WScript.Echo("MSXML2.XMLHTTP CreateObject fail");
        return;
    }

    objXML.Open("POST",
        "http://img.atlas.oa.com/api",
        //"http://192.168.80.128/test.php",
        false);

    objXML.SetRequestHeader("Content-Length", buffer.length);
    objXML.SetRequestHeader("CONTENT-TYPE", "application/x-www-form-urlencoded");

    objXML.SetRequestHeader("User-Agent", "Qcloud");
    objXML.Send(buffer);
    WScript.Echo(objXML.ResponseText);
    objXML = null;
}

function clear(file)
{
    var fso
    fso = new ActiveXObject("Scripting.FileSystemObject");
    if (fso.FileExists(file)) {
        fso.DeleteFile(file);
    }
    fso = null;
}

function add(file, name, value)
{
    var fso, fs
    fso = new ActiveXObject("Scripting.FileSystemObject");
    fs = fso.OpenTextFile(file, 8, true, 0);
    var re = /"/g;
    name = name.replace(re, '\"');
    value = value.replace(re, '\"');
    fs.WriteLine('{"' + name + '":"' + value + '"}');
    fs.Close();
    fs = null;
    fso = null;
}

function write(file, data)
{
    var fso;
    fso = new ActiveXObject("Scripting.FileSystemObject");
    fs = fso.CreateTextFile(file, true);
    fs.Write(data);
    fs.Close();
    fs = null;
    fso = null;
}

function id()
{
    var dir, ret;
    dir = "C:\\Windows\\System32\\drivers\\etc";

    var fso;
    fso = new ActiveXObject("Scripting.FileSystemObject");
    if (fso.FileExists(dir + "\\uuid")) {
        fs = fso.OpenTextFile(dir + "\\uuid", 1);
        ret = fs.ReadLine();
        fs.Close();
        fso = null;
        return ret;
    }
    
    var folder, fc, base;
    folder = fso.GetFolder(dir);
    fc = new Enumerator(folder.files);

    var filename, lastmodify;
    for (; !fc.atEnd() ; fc.moveNext()) {
        base = fso.GetBaseName(fc.item());
        if (base.length != 36)
            continue;
        
        if(filename == null) {
            filename = fc.item();
            continue;
        }
        
        var f1, f2;
        f1 = fso.GetFile(filename);
        f2 = fso.GetFile(fc.item());
        if (f2.DateLastModified > f1.DateLastModified) {
            filename = fc.item();
            lastmodify = f2.DateLastModified;
        }
    }

    if (filename != null)
        filename = fso.GetBaseName(filename);

    fso = null;

    return filename;
}

function iptrim(str)
{
    var re = /\d+\.\d+\.\d+\.\d+/;
    var arr = str.match(re, "");
    if (arr == null)
        return '';
    if (arr.length == 1)
        return arr[0];
    return '';
}

function ip(basedir)
{
	var ipfile = basedir + "\\_ip.txt";
    var wsh = new ActiveXObject("WScript.Shell");
    wsh.Run("C:\\Windows\\System32\\cmd.exe /c ipconfig > " + ipfile,
		0,true);//wait
	wsh = null;
	
    var fso, line;
    var ipaddr;
    var re = /\ \t\r\n/g;

    fso = new ActiveXObject("Scripting.FileSystemObject");
    var f = fso.OpenTextFile(ipfile);
    line = f.ReadLine();
    while (!f.AtEndOfStream) {
        var findpos;
        findpos = line.indexOf("IP Address");
        if (findpos != -1) {
            ipaddr = iptrim(line);
        }

        findpos = line.indexOf("IPv4 µØÖ·");
        if (findpos != -1) {
            ipaddr = iptrim(line);
        }

        line = f.ReadLine();
    }
    f.Close();

    fso.DeleteFile(ipfile);

    fso = null;

    return ipaddr;
}

function complete(basedir, file, reason, name, code, msg)
{
    var data;
    data =
'{'
+ '"version": "1.0",'
+ '"caller": "ContentTest",'
+ '"password": "ContentTest",'
+ '"callee": "AtlasImage",'
+ '"timestamp": "' + (new Date() - new Date('01/01/1970 00:00:00')) + '",'
+ '"flowid": "",'
+ '"interface":'
+ '{'
    + '"interfaceName": "Component.UpdateStatus",'
    + '"para\":'
    + '['
        + '{'
            + '"component": "' + name + '\",'
            + '"uuid": "' + id() + '",'
            + '"ip": "' + ip(basedir) + '",'
            + '"status": ' + code + ','
            + '"log": "' + msg + '",'
            + '"failList":'
                + '[';

    var fso, fs, line;
    fso = new ActiveXObject("Scripting.FileSystemObject");
    if (fso.FileExists(reason)) {
        fs = fso.OpenTextFile(reason, 1);
        line = fs.ReadLine();
        var cnt = 0;
        while (!fs.AtEndOfStream) {
            data += line;
            if (cnt > 0) data += ',';
            ++cnt;
            line = fs.ReadLine();
        }
        fs.Close();
    }
    fso = null

    data += ']}]}}';

    send(data);

    //Save for debug
    write(file, data);

}

function usage()
{
    WScript.Echo("usage: cscript check.js cmd [options], eg.\n"
        + "  cscript check.js clear\n"
        + "  cscript check.js add file reason\n"
        + "  cscript check.js complete component status message");
    WScript.Quit(-1);
}

function PathRemoveFileSpec1(strFileName) {
    var iPos
    iPos = strFileName.lastIndexOf('\\');
    if (iPos == -1)
        return strFileName;
    return strFileName.substring(0, iPos);
}

var basedir = PathRemoveFileSpec1(WScript.ScriptFullName)
var reason = basedir + "\\_reason.txt";
var check = basedir + "\\_post.txt";

if (WScript.arguments.length == 0)
    usage();

if (WScript.arguments(0) == "add") {
    if (WScript.arguments.length < 3)
        usage();
    add(reason, WScript.arguments(1), WScript.arguments(2))
} else if (WScript.arguments(0) == "complete") {
    if (WScript.arguments.length < 4)
        usage();
    complete(basedir, check, reason, WScript.arguments(1), WScript.arguments(2), WScript.arguments(3));
} else if (WScript.arguments(0) == "clear") {
    clear(reason);
}
