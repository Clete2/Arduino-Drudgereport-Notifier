#include <Client.h>
#include <Ethernet.h>
#include <SPI.h>
#include <LiquidCrystal.h>

byte mac[] = {0xCC, 0xAC, 0xBE, 0xEF, 0xFE, 0x91};
byte ip[] = {192, 168, 1, 144};
byte server[] = {157, 62, 210, 46}; // AKA csclub.mansfield.edu

String lastHeadline = "";
String headline = "";
short numNewlines = 0;

Client client(server, 80);
LiquidCrystal lcd(2, 3, 4, 5, 6, 7);

void setup(){
  Ethernet.begin(mac, ip);
  lcd.begin(16, 2);
  //Serial.begin(9600);
  
  delay(1000);
  
  startConnection();
}

void loop(){
  beginningSequence();
  endingSequence();
}

void beginningSequence(){
    if(client.available()){
      char c = client.read();
      
      if(c == '\n'){
        numNewlines++;
      }
      
      if(numNewlines == 8){ // 8 until we get to the desired text
        headline += c;
      }
  }
}

void endingSequence(){
  if(!client.connected()){
    stopConnection();
    delay(60000);
    startConnection();
  }
}

void startConnection(){
  lastHeadline = headline;
  headline = "";
  numNewlines = 0;
  
  //Serial.println("Connecting...");
  
  if(client.connect()){
    //Serial.println("Connected");
    client.println("GET /drudge.php HTTP/1.0");
    client.println();
  }else{
    //Serial.println("Connection failed");
  }
}

void stopConnection(){
    //Serial.println("Disconnecting");
    //Serial.print("Retrieved the text: ");
    //Serial.println(headline.substring(1, headline.length()));

    printToLCD(headline);

    if(!headline.equalsIgnoreCase(lastHeadline)){
      //Serial.println("New headline!");
      play_song();
      
      //Serial.println();
      client.stop();
      
      smtp_startConnection();
      smtp_send(headline);
      smtp_stopConnection();
    }else{
      //Serial.println();

      client.stop();
    }
}

void printToLCD(String text){ // Wraps text
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print(headline.substring(1, 16)); // Start at 1 to throw away the \n
  lcd.setCursor(0,1);
  lcd.print(headline.substring(16, headline.length()));
}
