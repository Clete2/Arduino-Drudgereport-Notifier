<?php

$drudgeConnection = fsockopen("drudgereport.com", 80, $errno, $errstr, 30);
$drudgeFullText = "";

if(!$drudgeConnection){
        echo "$errstr ($errno)<br />\n";
}else{
      	$out = "GET / HTTP/1.1\r\n";
        $out .= "Host: www.drudgereport.com\r\n";
        $out .= "Connection: Close\r\n\r\n";

        fwrite($drudgeConnection, $out);
        while (!feof($drudgeConnection)){
                $drudgeFullText .= fgets($drudgeConnection);
        }
        fclose($drudgeConnection);
}

//$regex = "/\<!\sMAIN\sHEADLINE\>.*\"\>(.*)\<\/A\>/"; // Could be improved, but it works as-is
//$regex = "/\<!\sMAIN\sHEADLINE\>.*\>(.*)\</";
$regex = "/\<!\sMAIN\sHEADLINE\>.*\<A\sHREF.*?\>(.*)\<\/A\>/";
preg_match($regex, $drudgeFullText, $drudgeHeadline);
print($drudgeHeadline[1]);
?>
