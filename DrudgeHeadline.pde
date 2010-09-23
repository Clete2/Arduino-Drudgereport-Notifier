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

short numNewlinesToExpect = 8; // Wait this many newlines until we start looking for our text
String urlToRead = "http://csclub.mansfield.edu/~clete2/drudge.php";

Client client(server, 80);
LiquidCrystal lcd(2, 3, 4, 5, 6, 7); // Change to your LCD pins. I recommend these pins as they do not interfere with the Ethernet shield.

void setup(){
  Ethernet.begin(mac, ip);
  lcd.begin(16, 2);
//  Serial.begin(9600);
  
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
    client.print("GET ");
    client.print(urlToRead);
    client.println(" HTTP/1.0");
    client.println();
  }else{
    //Serial.println("Connection failed");
  }
}

void stopConnection(){
    //Serial.println("Disconnecting");
    //Serial.print("Retrieved the text: ");
    //Serial.println(headline.substring(1, headline.length()));

    if(!headline.equalsIgnoreCase(lastHeadline) && !headline.equalsIgnoreCase("")){
      //Serial.println("New headline!");
      printToLCD(headline);
      play_song();
      
      client.stop();
      
      smtp_startConnection();
      smtp_send(headline);
      smtp_stopConnection();
    }else if(headline.equalsIgnoreCase("")){ // Failure; Set to previous headline to prevent new message next time
      headline = lastHeadline;
    }else{
      //Serial.println();

      client.stop();
    }
    
    //Serial.println();
}

void printToLCD(String text){ // Wraps text
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print(headline.substring(1, 17)); // Start at 1
  lcd.setCursor(0,1);

  if(headline.length() <= 33){
    lcd.print(headline.substring(17, headline.length()));
  }else{
    lcd.print(headline.substring(17, 33));
    
    for(int i = 33; i <= headline.length(); i += 32){ // Dynamically prints up to your headline
      delay(5000);
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print(headline.substring(i, i + 16));
      lcd.setCursor(0,1);
      
      if(headline.length() >= i + 32){ // Only print to end of headline
        lcd.print(headline.substring(i + 16, i + 32));
      }else{
        lcd.print(headline.substring(i + 16, headline.length()));
      }
    }
  }
}
